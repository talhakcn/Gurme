// Bir hesaba yönetici yetkisi verir ya da geri alır (Firebase özel yetkisi).
//
//   gcloud auth application-default login
//   corepack pnpm --filter @workspace/api-server exec tsx scripts/set-admin.ts e-posta@ornek.com
//   corepack pnpm --filter @workspace/api-server exec tsx scripts/set-admin.ts e-posta@ornek.com --remove
//
// Yetki, hesabın bir sonraki oturum yenilemesinde geçerli olur: uygulamada
// çıkış yapıp yeniden girmek en hızlısı.
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID ?? "gurme-511606";

async function main(): Promise<void> {
  const [email, flag] = process.argv.slice(2);
  if (!email || (flag && flag !== "--remove")) {
    console.error("Kullanım: tsx scripts/set-admin.ts <e-posta> [--remove]");
    process.exit(1);
  }
  const auth = getAuth(initializeApp({ projectId: PROJECT_ID }));
  const user = await auth.getUserByEmail(email);
  const admin = flag !== "--remove";
  // Varsa öteki özel yetkiler korunur.
  await auth.setCustomUserClaims(user.uid, { ...(user.customClaims ?? {}), admin });
  console.log(
    `${email} (${user.uid}): yönetici yetkisi ${admin ? "verildi" : "kaldırıldı"}. ` +
      "Uygulamada çıkış yapıp yeniden gir.",
  );
}

main().catch((error: unknown) => {
  console.error(String(error));
  process.exit(1);
});
