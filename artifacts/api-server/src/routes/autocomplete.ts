import { Router, type IRouter, type Request, type Response } from "express";
import axios from "axios";
import { logger } from "../lib/logger";
import { placesBudget } from "../search/places-budget";

const router: IRouter = Router();
const GOOGLE_PLACES_API_KEY = process.env.GOOGLE_PLACES_API_KEY;

router.get("/autocomplete", async (req: Request, res: Response) => {
  const input = (req.query.input as string || "").trim();
  if (!input || input.length < 2) {
    res.json({ suggestions: [] });
    return;
  }

  // Günlük Places sınırı dolduysa öneri verilmez; arama yine de yazılabilir.
  if (!GOOGLE_PLACES_API_KEY || !placesBudget.take()) {
    res.json({ suggestions: [] });
    return;
  }

  try {
    const response = await axios.post(
      "https://places.googleapis.com/v1/places:autocomplete",
      {
        input,
        languageCode: "tr",
      },
      {
        headers: {
          "X-Goog-Api-Key": GOOGLE_PLACES_API_KEY,
          "Content-Type": "application/json",
        },
      }
    );

    const suggestions = (response.data.suggestions ?? []).slice(0, 5).map((s: {
      placePrediction?: {
        placeId?: string;
        text?: { text?: string };
        structuredFormat?: { mainText?: { text?: string } };
      };
    }) => {
      const p = s.placePrediction;
      return {
        placeId: p?.placeId ?? "",
        description: p?.text?.text ?? "",
        mainText: p?.structuredFormat?.mainText?.text ?? p?.text?.text ?? "",
      };
    }).filter((s: { placeId: string }) => s.placeId);

    res.json({ suggestions });
  } catch (err) {
    logger.warn({ err, input }, "Autocomplete failed");
    res.json({ suggestions: [] });
  }
});

export default router;
