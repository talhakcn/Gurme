import { getApps, initializeApp } from "firebase-admin/app";
import { getAppCheck } from "firebase-admin/app-check";
import { getAuth } from "firebase-admin/auth";
import type { AuthVerifier } from "./auth";

export function createFirebaseVerifier(projectId: string): AuthVerifier {
  const app = getApps()[0] ?? initializeApp({ projectId });
  const auth = getAuth(app);
  const appCheck = getAppCheck(app);
  return {
    async verifyIdToken(token) {
      const decoded = await auth.verifyIdToken(token);
      return { uid: decoded.uid, email: decoded.email, admin: decoded.admin === true };
    },
    async verifyAppCheck(token) {
      await appCheck.verifyToken(token);
    },
  };
}
