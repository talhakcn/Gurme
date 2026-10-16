import { Router, type IRouter } from "express";
import { requireUser } from "../auth/auth";
import { istanbulDay } from "../auth/quota";
import { authConfig, quotaStore } from "../auth/runtime";

const router: IRouter = Router();

router.get("/me/quota", requireUser(authConfig), async (req, res) => {
  if (!req.user) {
    res.status(503).json({ error: "Hesap sistemi bu sunucuda yapılandırılmamış." });
    return;
  }
  try {
    res.json(await quotaStore().status(req.user.uid, istanbulDay(new Date())));
  } catch (err) {
    req.log.error({ err }, "Kota okunamadı");
    res.status(500).json({ error: "Kota bilgisi alınamadı." });
  }
});

export default router;
