// Türkçe metin yardımcıları: sorgu normalleştirme ve anahtar kelime eşleştirme.

const TR_LOWER: Record<string, string> = { I: "ı", İ: "i" };

/** Türkçe kurallarla küçük harf ("I" -> "ı", "İ" -> "i"). */
export function lowerTr(text: string): string {
  return text.replace(/[Iİ]/g, (c) => TR_LOWER[c]!).toLowerCase();
}

const FOLD: Record<string, string> = {
  ç: "c", ğ: "g", ı: "i", ö: "o", ş: "s", ü: "u", â: "a", î: "i", û: "u",
};

/**
 * Önbellek anahtarı ve eşleştirme için: Türkçe küçük harf, Türkçe harfler
 * sadeleşmiş, noktalama kaldırılmış, boşluklar tekleşmiş.
 * "  Köfte,  KADIKÖY " -> "kofte kadikoy"
 */
export function foldTr(text: string): string {
  return lowerTr(text.normalize("NFC"))
    .replace(/[çğıöşüâîû]/g, (c) => FOLD[c]!)
    .normalize("NFKD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^\p{L}\p{N}]+/gu, " ")
    .trim();
}

/** Kullanıcıya gösterilecek sorgu: baştaki/sondaki ve tekrarlanan boşluklar temizlenir. */
export function cleanQuery(text: string): string {
  return text.normalize("NFC").replace(/\s+/g, " ").trim();
}

/**
 * [text] içinde anahtar kelimelerden biri geçiyor mu (Türkçe harf duyarsız).
 * Uzun kelimeler ek alabildiği için kelime başından eşleşir ("bira" ->
 * "biracı"); 3 harfe kadar olanlar tam kelime olmalıdır ("bar" ->
 * "Barbekü" ya da "Barış" eşleşmez).
 */
export function containsAny(text: string, keywords: readonly string[]): boolean {
  const folded = ` ${foldTr(text)} `;
  return keywords.some((kw) => {
    const k = foldTr(kw);
    return folded.includes(k.length <= 3 ? ` ${k} ` : ` ${k}`);
  });
}

/** Sorgudaki anlamlı (3 harften uzun) kelimeler. */
export function significantWords(text: string): string[] {
  return foldTr(text)
    .split(" ")
    .filter((w) => w.length > 3);
}
