import { Router, type IRouter } from "express";
import healthRouter from "./health";
import searchRouter from "./search";
import autocompleteRouter from "./autocomplete";
import feedbackRouter from "./feedback";
import gurmeListsRouter from "./gurme-lists";
import meRouter from "./me";
import moderationRouter from "./moderation";
import adminRouter from "./admin";

const router: IRouter = Router();

router.use(healthRouter);
router.use(searchRouter);
router.use(autocompleteRouter);
router.use(feedbackRouter);
router.use(gurmeListsRouter);
router.use(meRouter);
router.use(moderationRouter);
router.use(adminRouter);

export default router;
