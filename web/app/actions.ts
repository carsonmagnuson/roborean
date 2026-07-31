"use server";

import { db } from "@/db";
import { words } from "@/db/schema";
import { eq } from "drizzle-orm";
import { fetchDefinition, getScore } from "@/lib/obscurity_util";

export async function lookupWord(word: string) {
  const normalized = word.trim().toLowerCase();
  if (!normalized) return null;

  const [cached] = await db.select().from(words).where(eq(words.word, normalized));

  let entries = cached?.entries ?? null;
  const score = await getScore(normalized);

  if (!entries) {
    entries = await fetchDefinition(normalized);
    if (!entries) {
      if (score) return { word: normalized, score: Math.round(score * 10) / 10, entries}
      else return { word: normalized, notFound: true as const };
    }


    await db
      .insert(words)
      .values({ word: normalized, entries})
      .onConflictDoUpdate({ target: words.word, set: { entries } });
  }

  return { word: normalized, score: score ? (Math.round(score * 10) / 10) : null, entries };
}

