"use server";

import { revalidatePath } from "next/cache";
import { db } from "@/db";
import { words } from "@/db/schema";
import { eq } from "drizzle-orm";
import { fetchDefinition, getScore } from "@/lib/obscurity_util";


export async function addWord(formData: FormData) {
  const word = String(formData.get("word") ?? "").trim();
  const meaning = String(formData.get("meaning") ?? "").trim();

  if (!word) return;

  await db.insert(words).values({ word, meaning }).onConflictDoUpdate({
    target: words.word,
    set: { meaning },
  });

  revalidatePath("/");

}

export async function lookupWord(word: string) {
  const normalized = word.trim().toLowerCase();
  if (!normalized) return null;

  const [cached] = await db.select().from(words).where(eq(words.word, normalized));

  let entries = cached?.entries ?? null;

  if (!entries) {
    entries = await fetchDefinition(normalized);
    if (!entries) return { word: normalized, notFound: true as const };

    await db
      .insert(words)
      .values({ word: normalized, entries, meaning: "" })
      .onConflictDoUpdate({ target: words.word, set: { entries } });
  }

  const score = await getScore(normalized);
  return { word: normalized, score, entries };
}


export async function deleteWord(formData: FormData) {
  const id = Number(formData.get("id"));

  if (!Number.isInteger(id)) return;

  await db.delete(words).where(eq(words.id, id));

  revalidatePath("/");

}
