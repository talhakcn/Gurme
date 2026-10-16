import express, { type Express } from "express";
import cors, { type CorsOptions } from "cors";
import pinoHttp from "pino-http";
import { authenticate, requireAppCheck } from "./auth/auth";
import { authConfig } from "./auth/runtime";
import router from "./routes";
import { touchSignedInUser } from "./lib/touch-user";
import { logger } from "./lib/logger";
import { budgetUser } from "./search/places-budget";
import {
  apiLimiter,
  autocompleteLimiter,
  insightLimiter,
  listWriteLimiter,
  searchLimiter,
} from "./middlewares/rate-limit";

const app: Express = express();

// Cloud Run tek bir Google önyüz proxy'si arkasında çalışır; gerçek istemci IP'si
// (hız sınırı için) X-Forwarded-For başlığındaki ilk atlamadan okunur.
app.set("trust proxy", 1);

app.use(
  pinoHttp({
    logger,
    serializers: {
      req(req) {
        return {
          id: req.id,
          method: req.method,
          url: req.url?.split("?")[0],
        };
      },
      res(res) {
        return {
          statusCode: res.statusCode,
        };
      },
    },
  }),
);

// Mobil uygulamalar Origin başlığı göndermez, CORS onları etkilemez. Tarayıcıdan
// erişime yalnızca ALLOWED_ORIGINS listesindeki adresler için izin verilir.
// Geliştirme ortamında liste boşsa tüm adreslere izin verilir.
const allowedOrigins = (process.env.ALLOWED_ORIGINS ?? "")
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);
const corsOptions: CorsOptions = {
  origin: allowedOrigins.length > 0
    ? allowedOrigins
    : process.env.NODE_ENV !== "production",
};
app.use(cors(corsOptions));
app.use(express.json({ limit: "100kb" }));
app.use(express.urlencoded({ extended: true, limit: "100kb" }));

app.use("/api", apiLimiter);
// Firebase ID token varsa doğrulanır (req.user); App Check yalnızca maliyetli
// Google ve yapay zekâ uçlarında istenir.
app.use("/api", authenticate(authConfig));
// Google'a giden çağrılar günlük sayaçta isteği yapan kullanıcıya yazılır.
app.use("/api", (req, _res, next) => budgetUser.run(req.user?.uid, next));
// Giriş yapmış her hesap kullanıcılar tablosunda görünsün (yönetim paneli);
// yalnızca arama yapanlar değil. Saatte en çok bir kez yazılır.
app.use("/api", touchSignedInUser);
app.use(["/api/search", "/api/places", "/api/autocomplete"], requireAppCheck(authConfig));
app.use("/api/search", searchLimiter);
app.use("/api/places", insightLimiter);
app.use("/api/autocomplete", autocompleteLimiter);
app.use("/api/gurme/lists", listWriteLimiter);
app.use("/api", router);

export default app;
