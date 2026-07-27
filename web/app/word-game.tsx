"use client";

import { useState, useTransition } from "react";
import { lookupWord } from "./actions";
import type { DictEntry } from "@/db/schema";

type Result = {
  word: string;
  score?: number | null;
  entries?: DictEntry[] | null;
  notFound?: boolean;
};

export function tierName(r: Result): string {
  if (r.notFound) return "unknown";
  if (r.score == null) return "lost";
  if (r.score < 4) return "common";
  if (r.score < 5) return "uncommon";
  if (r.score < 6.5) return "rare";
  return "mythic";
}

export function tierStyles(r: Result): string {
  if (r.notFound) return "border-l-neutral-700 text-neutral-500";     // unknown
  if (r.score == null) return "border-l-amber-400 text-amber-300";    // lost
  if (r.score < 4) return "border-l-neutral-500 text-neutral-400";    // common
  if (r.score < 5) return "border-l-green-500 text-green-300";        // uncommon
  if (r.score < 6.5) return "border-l-blue-500 text-blue-300";        // rare
  return "border-l-violet-500 text-violet-300";                       // mythic
}

export default function WordGame() {
  const [results, setResults] = useState<Result[]>([]);
  const [input, setInput] = useState("");
  const [isPending, startTransition] = useTransition();

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const word = input.trim().toLowerCase();
    if (!word) return;

    if (results.some((r) => r.word === word)) {
      setInput("");
      return;
    }

    startTransition(async () => {
      const result = await lookupWord(word);
      if (result) setResults((prev) => [result, ...prev]);
      setInput("");
    });
  }

  return (
    <>
      <form onSubmit={handleSubmit} className="mb-8 flex gap-2">
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="enter a word"
          className="flex-1 border border-gray-300 rounded p-2"
        />
        <button
          type="submit"
          disabled={isPending}
          className="rounded px-5 font-semibold border border-neutral-700 text-neutral-200 hover:border-neutral-400 hover:text-white disabled:opacity-40 transition-colors"
        >
          {isPending ? "…" : "score"}
        </button>
      </form>

      <ul className="space-y-3">
        {results.map((r, i) => (
          <li key={i} className={`relative p-4 rounded-lg border ${tierStyles(r)}`}>
            <span className="absolute top-3 right-3 rounded border border-current px-2 py-0.5 text-[10px] uppercase tracking-widest font-mono -rotate-3 opacity-70">
              {tierName(r)}
            </span>
            <strong className="text-2xl font-serif">{r.word}</strong>
            {r.notFound ? (
              <p className="text-gray-500 text-sm">not a word we know</p>
            ) : (
              <>
                {r.score != null && (
                  <span className="ml-2 text-xs font-mono text-violet-300">
                    {r.score.toFixed(1)}
                  </span>
                )}
                {r.entries?.map((entry, j) => (
                  <div key={j} className="mt-2">
                    <span className="text-xs italic text-gray-500">
                      {entry.pos}
                    </span>
                    <ol className="list-decimal list-inside text-gray-600">
                      {entry.senses.map((s, k) => (
                        <li key={k}>{s}</li>
                      ))}
                    </ol>
                  </div>
                ))}
              </>
            )}
          </li>
        ))}
      </ul>
    </>
  );
}
