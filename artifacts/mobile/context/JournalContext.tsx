import AsyncStorage from "@react-native-async-storage/async-storage";
import React, { createContext, useContext, useEffect, useState } from "react";
import { Text, View } from "react-native";
import type { GurmeList, GurmeListVisibility } from "@workspace/api-client-react";
import { C } from "@/constants/colors";

export type Status = "want" | "went" | "recommend";
export type Place = { id: string; name: string; district: string; city: string; address?: string; category: string; description: string; image?: string; status?: Status; recommended?: boolean; createdAt: string };
export type Visit = { id: string; placeId: string; date: string; title: string; note: string; order?: string; recommended: boolean; revisit: "yes" | "no" | "undecided"; dishes: string; photos: string[]; visibility: "private" | "public" };
export type ListItem = { placeId: string; note: string };
export type CuratedList = { id: string; title: string; description: string; city: string; items: ListItem[]; createdAt: string; updatedAt: string; remoteId?: string; ownerKey?: string; visibility?: GurmeListVisibility };
export type Profile = { name: string; handle: string; bio: string; city: string; interests: string; areas: string; defaultVisitVisibility: "private" | "public"; privateJournal: boolean; notifications: boolean };
type Data = { places: Place[]; visits: Visit[]; lists: CuratedList[]; savedListIds: string[]; savedRemoteLists: GurmeList[]; profile: Profile };
type Journal = Data & {
  loaded: boolean;
  addPlace: (input: Omit<Place, "id" | "createdAt">) => string;
  updatePlace: (id: string, update: Partial<Place>) => void;
  deletePlace: (id: string) => void;
  setStatus: (id: string, status?: Status) => void;
  saveVisit: (input: Omit<Visit, "id"> & { id?: string }) => string;
  deleteVisit: (id: string) => void;
  saveList: (input: Omit<CuratedList, "id" | "createdAt" | "updatedAt"> & { id?: string }) => string;
  linkRemoteList: (id: string, remoteId: string, ownerKey: string, visibility: GurmeListVisibility) => void;
  setListVisibility: (id: string, visibility: GurmeListVisibility) => void;
  deleteList: (id: string) => void;
  toggleSaved: (id: string) => void;
  toggleRemoteSaved: (list: GurmeList) => void;
  updateProfile: (update: Partial<Profile>) => void;
};
const initial: Data = {
  places: [], visits: [], lists: [], savedListIds: [], savedRemoteLists: [],
  profile: { name: "", handle: "", bio: "", city: "", interests: "", areas: "", defaultVisitVisibility: "private", privateJournal: true, notifications: false },
};
const KEY = "@gurme_journal_v1";
const uid = () => `${Date.now().toString(36)}${Math.random().toString(36).slice(2, 9)}`;
const Context = createContext<Journal | null>(null);
export function JournalProvider({ children }: { children: React.ReactNode }) {
  const [data, setData] = useState<Data>(initial);
  const [loaded, setLoaded] = useState(false);
  const [storageError, setStorageError] = useState("");
  useEffect(() => {
    AsyncStorage.getItem(KEY).then(raw => {
      if (raw) {
        try {
          const stored = JSON.parse(raw) as Partial<Data>;
          setData({
            ...initial, ...stored,
            profile: { ...initial.profile, ...stored.profile },
            places: (stored.places || []).map(p => p.status === "recommend" ? { ...p, status: "went", recommended: true } : p),
            visits: (stored.visits || []).map(v => ({ ...v, revisit: v.revisit || "undecided", dishes: v.dishes || "", photos: v.photos || [], visibility: v.visibility || "private" })),
          });
        } catch { setStorageError("Kişisel defter okunamadı. Verilerin korunması için yeni kayıt yapılmadı. Uygulama verilerini silmeden önce destek alın."); }
      }
    }).catch(() => setStorageError("Kişisel defter açılamadı. Verilerin korunması için yeni kayıt yapılmadı."))
      .finally(() => setLoaded(true));
  }, []);
  useEffect(() => {
    if (loaded && !storageError) AsyncStorage.setItem(KEY, JSON.stringify(data))
      .catch(() => setStorageError("Defter kaydedilemedi. Mevcut kayıtları korumak için uygulamayı kapatmadan önce yeniden deneyin."));
  }, [data, loaded, storageError]);
  const addPlace: Journal["addPlace"] = input => {
    const id = uid(); setData(d => ({ ...d, places: [{ ...input, id, createdAt: new Date().toISOString() }, ...d.places] })); return id;
  };
  const updatePlace: Journal["updatePlace"] = (id, update) => setData(d => ({ ...d, places: d.places.map(p => p.id === id ? { ...p, ...update } : p) }));
  const deletePlace: Journal["deletePlace"] = id => setData(d => ({
    ...d, places: d.places.filter(p => p.id !== id), visits: d.visits.filter(v => v.placeId !== id),
    lists: d.lists.map(l => ({ ...l, items: l.items.filter(i => i.placeId !== id) })),
  }));
  const setStatus: Journal["setStatus"] = (id, status) => {
    if (status === "recommend") {
      setData(d => ({ ...d, places: d.places.map(p => p.id === id ? { ...p, status: "went", recommended: !p.recommended } : p) }));
    } else updatePlace(id, status === "want" ? { status, recommended: false } : { status });
  };
  const saveVisit: Journal["saveVisit"] = input => {
    const id = input.id || uid(); const visit = { ...input, id };
    setData(d => ({ ...d, visits: [visit, ...d.visits.filter(v => v.id !== id)], places: d.places.map(p => p.id === input.placeId ? { ...p, status: "went" as const, recommended: input.recommended || p.recommended } : p) })); return id;
  };
  const deleteVisit: Journal["deleteVisit"] = id => setData(d => ({ ...d, visits: d.visits.filter(v => v.id !== id) }));
  const saveList: Journal["saveList"] = input => {
    const id = input.id || uid(); const prior = data.lists.find(l => l.id === id);
    const list: CuratedList = { ...prior, ...input, id, createdAt: prior?.createdAt || new Date().toISOString(), updatedAt: new Date().toISOString() };
    setData(d => ({ ...d, lists: [list, ...d.lists.filter(l => l.id !== id)] })); return id;
  };
  const linkRemoteList: Journal["linkRemoteList"] = (id, remoteId, ownerKey, visibility) =>
    setData(d => ({ ...d, lists: d.lists.map(l => l.id === id ? { ...l, remoteId, ownerKey, visibility } : l) }));
  const setListVisibility: Journal["setListVisibility"] = (id, visibility) =>
    setData(d => ({ ...d, lists: d.lists.map(l => l.id === id ? { ...l, visibility } : l) }));
  const deleteList: Journal["deleteList"] = id => setData(d => ({ ...d, lists: d.lists.filter(l => l.id !== id), savedListIds: d.savedListIds.filter(x => x !== id) }));
  const toggleSaved: Journal["toggleSaved"] = id => setData(d => ({ ...d, savedListIds: d.savedListIds.includes(id) ? d.savedListIds.filter(x => x !== id) : [...d.savedListIds, id] }));
  const toggleRemoteSaved: Journal["toggleRemoteSaved"] = list => setData(d => ({
    ...d, savedRemoteLists: d.savedRemoteLists.some(l => l.id === list.id)
      ? d.savedRemoteLists.filter(l => l.id !== list.id)
      : [list, ...d.savedRemoteLists],
  }));
  const updateProfile: Journal["updateProfile"] = update => setData(d => ({ ...d, profile: { ...d.profile, ...update } }));
  if (!loaded || storageError) return <View style={{ flex: 1, justifyContent: "center", padding: 28, backgroundColor: C.paper }}>
    <Text style={{ color: C.ink, fontSize: 22, marginBottom: 14 }}>{storageError ? "Defterin açılamadı" : "Gurme açılıyor…"}</Text>
    {!!storageError && <Text style={{ color: C.ink, fontSize: 15, lineHeight: 24 }}>{storageError}</Text>}
  </View>;
  return <Context.Provider value={{ ...data, loaded, addPlace, updatePlace, deletePlace, setStatus, saveVisit, deleteVisit, saveList, linkRemoteList, setListVisibility, deleteList, toggleSaved, toggleRemoteSaved, updateProfile }}>{children}</Context.Provider>;
}
export function useJournal() {
  const value = useContext(Context);
  if (!value) throw new Error("JournalProvider missing");
  return value;
}