import { integer, pgTable, text, timestamp } from "drizzle-orm/pg-core";

export const words = pgTable("words", {
  id: integer("id").primaryKey().generatedAlwaysAsIdentity(),
  word: text("word").notNull().unique(),
  meaning: text("meaning").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
