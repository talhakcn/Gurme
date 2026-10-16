import assert from "node:assert/strict";
import { test } from "node:test";
import { createPlacePhotos, PLACE_ID_PATTERN, type PhotoHttpGet } from "./place-photos";
import { PlacesBudget, PlacesBudgetExceeded } from "./places-budget";

function fakeGet(photos: unknown): { get: PhotoHttpGet; urls: string[] } {
  const urls: string[] = [];
  const get: PhotoHttpGet = async (url) => {
    urls.push(url);
    if (url.endsWith("/media")) return { data: { photoUri: "https://lh3.example/p.jpg" } };
    return { data: photos };
  };
  return { get, urls };
}

test("ilk fotoğrafın adresi ve çekeni döner", async () => {
  const { get, urls } = fakeGet({
    photos: [
      {
        name: "places/ChIJabc123456/photos/AAA",
        authorAttributions: [{ displayName: "Ayşe K.", uri: "https://maps.example/ayse" }],
      },
    ],
  });
  const photo = await createPlacePhotos("k", new PlacesBudget(10), get).photo("ChIJabc123456");
  assert.deepEqual(photo, {
    uri: "https://lh3.example/p.jpg",
    author: { name: "Ayşe K.", uri: "https://maps.example/ayse" },
  });
  assert.deepEqual(urls, [
    "https://places.googleapis.com/v1/places/ChIJabc123456",
    "https://places.googleapis.com/v1/places/ChIJabc123456/photos/AAA/media",
  ]);
});

test("fotoğrafı olmayan mekânda tek istek yapılır", async () => {
  const { get, urls } = fakeGet({});
  const budget = new PlacesBudget(10);
  assert.equal(await createPlacePhotos("k", budget, get).photo("ChIJabc123456"), null);
  assert.equal(urls.length, 1);
});

test("bütçe dolunca Google'a gidilmez", async () => {
  const { get, urls } = fakeGet({ photos: [{ name: "places/x/photos/y" }] });
  const photos = createPlacePhotos("k", new PlacesBudget(1), get);
  await assert.rejects(photos.photo("ChIJabc123456"), PlacesBudgetExceeded);
  assert.equal(urls.length, 1);
});

test("mekân kimliği yol karakteri içeremez", () => {
  assert.ok(PLACE_ID_PATTERN.test("ChIJN1t_tDeuEmsRUsoyG83frY4"));
  assert.ok(!PLACE_ID_PATTERN.test("../../v1/places:searchText"));
  assert.ok(!PLACE_ID_PATTERN.test("abc/photos"));
});
