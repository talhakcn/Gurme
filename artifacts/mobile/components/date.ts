export function displayDate(value: string | undefined): string {
  if (!value) return "Tarih yok";
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? "Tarih yok" : date.toLocaleDateString("tr-TR", { day: "numeric", month: "long", year: "numeric" });
}