import { and, countDistinct, inArray, sql } from "drizzle-orm";
import type { NodePgDatabase } from "drizzle-orm/node-postgres";
import { venueReportsTable } from "@workspace/db/schema";

/** Bu kadar farklı kişi bildirirse mekân "doğrulama gerekli" olarak işaretlenir. */
export const VERIFICATION_REPORT_THRESHOLD = 3;

/**
 * Bildirimi yapan kişi: hesap varsa kullanıcı, yoksa kurulum. Sahte kurulum
 * kimlikleriyle tek kişinin birden çok bildirim sayılmasını engeller.
 */
export const reporterKey = sql<string>`coalesce(${venueReportsTable.userId}, ${venueReportsTable.installationId})`;

export function createFlaggedPlaces(db: NodePgDatabase<Record<string, unknown>>) {
  return async (placeIds: string[]): Promise<Set<string>> => {
    if (placeIds.length === 0) return new Set();
    const rows = await db
      .select({
        placeId: venueReportsTable.placeId,
        reporters: countDistinct(reporterKey),
      })
      .from(venueReportsTable)
      .where(
        and(
          inArray(venueReportsTable.placeId, placeIds),
          inArray(venueReportsTable.status, ["open", "accepted"]),
        ),
      )
      .groupBy(venueReportsTable.placeId);
    return new Set(
      rows.filter((r) => r.reporters >= VERIFICATION_REPORT_THRESHOLD).map((r) => r.placeId),
    );
  };
}
