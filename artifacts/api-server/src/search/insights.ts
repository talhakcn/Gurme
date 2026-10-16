import { GoogleGenAI } from "@google/genai";
import axios from "axios";
import { z } from "zod/v4";
import type { PlaceInsightFeatures, PlaceInsightSummary } from "@workspace/db/schema";
import { logger } from "../lib/logger";
import type { GooglePlace } from "./google-places";

/** Bir mekânın sorgudan bağımsız, bir kez çıkarılan analizi. */
export interface PlaceInsight {
  placeId: string;
  features: PlaceInsightFeatures;
  summary: PlaceInsightSummary;
  reviewCount: number;
  model: string;
  analyzedAt: Date;
}

export interface AiProvider {
  /** Kayıtlarda görünen model adı. */
  readonly model: string;
  complete(prompt: string): Promise<string>;
}

export interface InsightAnalyzer {
  /** Analiz edilemeyen mekânlar sonuçta yer almaz. */
  analyze(places: GooglePlace[]): Promise<PlaceInsight[]>;
}

export const VIBE_TAGS = [
  "cozy", "sakin", "romantik", "enerjik", "çalışmalık", "estetik", "samimi", "nostaljik",
  "lokal his", "instagramlık", "lüks his", "aile dostu", "grup ortamı", "date için",
] as const;

const signal = z.enum(["yes", "no", "unknown"]).catch("unknown");
const shortList = (max: number, maxLength: number) =>
  z
    .array(z.string())
    .catch([])
    .transform((items) =>
      items
        .map((s) => s.trim())
        .filter(Boolean)
        .slice(0, max)
        .map((s) => s.slice(0, maxLength)),
    );

const aiItem = z.object({
  summary: z.string().catch("").transform((s) => s.trim().slice(0, 240)),
  whyGo: shortList(2, 100),
  warnings: shortList(2, 90),
  vibeTags: z
    .array(z.string())
    .catch([])
    .transform((tags) => tags.filter((t): t is (typeof VIBE_TAGS)[number] => (VIBE_TAGS as readonly string[]).includes(t)).slice(0, 4)),
  highlights: shortList(5, 40),
  alcohol: signal,
  helal: signal,
  glutenFree: signal,
  celiacSafe: signal,
});

export function buildPrompt(places: GooglePlace[]): string {
  const blocks = places
    .map((p, i) => {
      const reviews = p.reviews
        .slice(0, 5)
        .map((r) => `- (${r.rating}/5) ${r.text.slice(0, 600)}`)
        .join("\n");
      return `=== ${i + 1}: ${p.name}${p.types.length ? ` [${p.types.slice(0, 6).join(", ")}]` : ""} ===\n${reviews || "Yorum yok."}`;
    })
    .join("\n\n");

  return `Sen deneyimli bir Türk gurme editörüsün. Aşağıda ${places.length} mekânın Google yorumları var. Her mekân için yalnızca bu yorumlara dayanarak kısa bir analiz çıkar. Yorumlarda olmayan hiçbir şeyi uydurma.

${blocks}

SADECE ${places.length} elemanlı bir JSON dizisi döndür, sıra mekân sırasıyla aynı olsun, başka hiçbir şey yazma:
[
  {
    "summary": "Tek cümlelik özet",
    "whyGo": ["neden gidilir 1", "neden gidilir 2"],
    "warnings": [],
    "vibeTags": ["samimi"],
    "highlights": ["öne çıkan ürün"],
    "alcohol": "unknown",
    "helal": "unknown",
    "glutenFree": "unknown",
    "celiacSafe": "unknown"
  }
]

KURALLAR:
- "summary": En fazla 200 karakter, mekânın ne olduğunu ve neyle öne çıktığını anlatır.
- "whyGo": Tam olarak 2 madde, her biri en fazla 80 karakter, yorumlardan damıtılmış.
- "warnings": Yalnızca yorumlarda geçen gerçek olumsuzluklar, en fazla 2 madde. Yoksa []. Jenerik uyarı uydurma.
- "vibeTags": 2-4 etiket, yalnızca şu listeden: ${VIBE_TAGS.join(", ")}.
- "highlights": Yorumlarda övülen en fazla 5 yiyecek veya içecek adı. Yoksa [].
- "alcohol": Yorumlarda içki, bira, şarap, rakı, kokteyl, meyhane gibi servis kanıtı varsa "yes"; yorumlar açıkça alkol olmadığını söylüyorsa "no"; yoksa "unknown".
- "helal": Yorumlar helal olduğunu açıkça söylüyorsa "yes"; domuz eti ya da helal olmadığı geçiyorsa "no"; yoksa "unknown".
- "glutenFree": Glutensiz seçenek açıkça geçiyorsa "yes"; olmadığı söyleniyorsa "no"; yoksa "unknown".
- "celiacSafe": Çölyak hastaları için ayrı hazırlık ya da güvenli olduğu açıkça geçiyorsa "yes"; çapraz bulaşma ya da güvensizlik geçiyorsa "no"; yoksa "unknown". Yalnızca glutensiz menü olması "yes" için yetmez.
- Emin değilsen "unknown" yaz. Türkçe ve akıcı yaz.`;
}

/** Model yanıtındaki JSON dizisini okur; bozuk ya da eksik elemanlar `null`. */
export function parseInsights(text: string, count: number): Array<z.infer<typeof aiItem> | null> {
  const match = text.match(/\[[\s\S]*\]/);
  if (!match) throw new Error("Yanıtta JSON dizisi yok");
  const raw: unknown = JSON.parse(match[0]);
  if (!Array.isArray(raw)) throw new Error("Yanıt bir dizi değil");
  return Array.from({ length: count }, (_, i) => {
    const parsed = aiItem.safeParse(raw[i]);
    // whyGo boşsa model bu mekânı analiz etmemiştir; uydurma sonuç saklanmaz.
    return parsed.success && parsed.data.whyGo.length > 0 ? parsed.data : null;
  });
}

export function createAnalyzer(providers: AiProvider[], now: () => Date = () => new Date()): InsightAnalyzer {
  return {
    async analyze(places) {
      const analyzable = places.filter((p) => p.reviews.length > 0);
      if (analyzable.length === 0 || providers.length === 0) return [];
      const prompt = buildPrompt(analyzable);
      for (const provider of providers) {
        try {
          const items = parseInsights(await provider.complete(prompt), analyzable.length);
          return analyzable.flatMap((place, i) => {
            const item = items[i];
            if (!item) return [];
            const { alcohol, helal, glutenFree, celiacSafe, ...summary } = item;
            return [
              {
                placeId: place.id,
                features: { alcohol, helal, glutenFree, celiacSafe },
                summary,
                reviewCount: place.reviews.length,
                model: provider.model,
                analyzedAt: now(),
              },
            ];
          });
        } catch (err) {
          logger.warn({ err: String(err), model: provider.model }, "Mekân analizi başarısız; sıradaki sağlayıcı deneniyor");
        }
      }
      return [];
    },
  };
}

async function withRetry<T>(call: () => Promise<T>, isRetryable: (err: unknown) => boolean): Promise<T> {
  let delayMs = 2000;
  for (let attempt = 0; ; attempt++) {
    try {
      return await call();
    } catch (err) {
      if (attempt >= 2 || !isRetryable(err)) throw err;
      await new Promise((r) => setTimeout(r, delayMs));
      delayMs *= 2;
    }
  }
}

const retryableStatus = (status: number | undefined) => status === 429 || status === 500 || status === 503;

export function deepSeekProvider(apiKey: string): AiProvider {
  return {
    model: "deepseek-chat",
    complete: (prompt) =>
      withRetry(
        async () => {
          const response = await axios.post(
            "https://api.deepseek.com/chat/completions",
            { model: "deepseek-chat", messages: [{ role: "user", content: prompt }], temperature: 0.4 },
            { headers: { Authorization: `Bearer ${apiKey}` }, timeout: 30_000 },
          );
          return String(response.data.choices?.[0]?.message?.content ?? "");
        },
        (err) => retryableStatus((err as { response?: { status?: number } }).response?.status),
      ),
  };
}

export function geminiProvider(apiKey: string, model = "gemini-3.1-flash-lite"): AiProvider {
  const client = new GoogleGenAI({ apiKey });
  return {
    model,
    complete: (prompt) =>
      withRetry(
        async () => {
          const result = await client.models.generateContent({
            model,
            contents: [{ role: "user", parts: [{ text: prompt }] }],
          });
          return result.text ?? "";
        },
        (err) => retryableStatus((err as { status?: number }).status),
      ),
  };
}

/** Ortam değişkenlerine göre sağlayıcılar: önce DeepSeek, hata olursa Gemini. */
export function providersFromEnv(env: NodeJS.ProcessEnv): AiProvider[] {
  return [
    ...(env.DEEPSEEK_API_KEY ? [deepSeekProvider(env.DEEPSEEK_API_KEY)] : []),
    ...(env.GEMINI_API_KEY ? [geminiProvider(env.GEMINI_API_KEY)] : []),
  ];
}
