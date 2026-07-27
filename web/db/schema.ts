import { integer, pgTable, text, timestamp, jsonb } from "drizzle-orm/pg-core";

export type DictEntry = { pos: string; senses: string[] }

export const words = pgTable("words", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  word: text("word").notNull().unique(),
  entries: jsonb("entries").$type<DictEntry[]>(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});


