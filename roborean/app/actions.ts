"use server";

import { revalidatePath } from "next/cache";
import { db } from "@/db";
import { words } from "@/db/schema";


export async function addWord(formData: FormData) {
  const word = String(formData.get("word") ?? "").trim();
  const meaning = String(formData.get("meaning") ?? "").trim();

  if (!word || !meaning) return;

  await db.insert(words).values({ word, meaning }).onConflictDoUpdate({
    target: words.word,
    set: { meaning },
  });

  revalidatePath("/");


};
