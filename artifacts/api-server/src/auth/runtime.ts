import { db } from "@workspace/db";
import { authConfigFromEnv, type AuthConfig } from "./auth";
import { createPgQuotaStore, type QuotaStore } from "./quota";

let config: AuthConfig | undefined;
let quota: QuotaStore | undefined;

/** Ortamdan bir kez okunur; testlerde `setAuthForTesting` ile değiştirilir. */
export function authConfig(): AuthConfig {
  return (config ??= authConfigFromEnv(process.env));
}

export function quotaStore(): QuotaStore {
  return (quota ??= createPgQuotaStore(db));
}

export function setAuthForTesting(value: AuthConfig | undefined, store?: QuotaStore): void {
  config = value;
  quota = store;
}
