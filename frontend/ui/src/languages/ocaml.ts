import type { Monaco } from "@monaco-editor/react";

let monacoInitialized = false;

export function initializeOcamlLanguage(monaco: Monaco): void {
  if (monacoInitialized) return;
  monacoInitialized = true;

  if (
    !monaco.languages
      .getLanguages()
      .some((lang: { id: string }) => lang.id === "ocaml")
  ) {
    monaco.languages.register({ id: "ocaml" });
  }

  monaco.languages.setMonarchTokensProvider("ocaml", {
    keywords: [
      "and", "as", "assert", "asr", "begin", "class", "constraint", "do",
      "done", "downto", "else", "end", "exception", "external", "false",
      "for", "fun", "function", "functor", "if", "in", "include", "inherit",
      "initializer", "land", "lazy", "let", "lor", "lsl", "lsr", "lxor",
      "match", "method", "mod", "module", "mutable", "new", "nonrec", "object",
      "of", "open", "or", "private", "rec", "sig", "struct", "then", "to",
      "true", "try", "type", "val", "virtual", "when", "while", "with",
    ],
    operators: [
      "=", ">", "<", "!", "~", "?", ":", "==", "<=", ">=", "!=", "&&", "||",
      "++", "--", "+", "-", "*", "/", "&", "|", "^", "%", "<<", ">>", ">>>",
      "+=", "-=", "*=", "/=", "&=", "|=", "^=", "%=", "<<=", ">>=", ">>>=",
    ],
    symbols: /[=><!~?:&|+\-*\/\^%]+/,
    escapes:
      /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,

    tokenizer: {
      root: [
        [
          /[a-z_$][\w$]*/,
          { cases: { "@keywords": "keyword", "@default": "identifier" } },
        ],
        [/[A-Z][\w$]*/, "type.identifier"],
        { include: "@whitespace" },
        [/[{}()\[\]]/, "@brackets"],
        [/[<>](?!@symbols)/, "@brackets"],
        [/@symbols/, { cases: { "@operators": "operator", "@default": "" } }],
        [/\d*\.\d+([eE][\-+]?\d+)?/, "number.float"],
        [/0[xX][0-9a-fA-F]+/, "number.hex"],
        [/\d+/, "number"],
        [/"([^"\\]|\\.)*$/, "string.invalid"],
        [/"/, { token: "string.quote", bracket: "@open", next: "@string" }],
        [/'[^\\']'/, "string"],
        [/(')(@escapes)(')/, ["string", "string.escape", "string"]],
        [/'/, "string.invalid"],
      ],
      comment: [
        [/[^\(*]+/, "comment"],
        [/\(\*/, "comment", "@push"],
        [/\*\)/, "comment", "@pop"],
        [/[\(*]/, "comment"],
      ],
      string: [
        [/[^\\"]+/, "string"],
        [/@escapes/, "string.escape"],
        [/\\./, "string.escape.invalid"],
        [/"/, { token: "string.quote", bracket: "@close", next: "@pop" }],
      ],
      whitespace: [
        [/[ \t\r\n]+/, "white"],
        [/\(\*/, "comment", "@comment"],
      ],
    },
  });

  monaco.languages.setLanguageConfiguration("ocaml", {
    comments: { blockComment: ["(*", "*)"] },
    brackets: [
      ["{", "}"],
      ["[", "]"],
      ["(", ")"],
    ],
    autoClosingPairs: [
      { open: "{", close: "}" },
      { open: "[", close: "]" },
      { open: "(", close: ")" },
      { open: '"', close: '"' },
      { open: "'", close: "'" },
    ],
    surroundingPairs: [
      { open: "{", close: "}" },
      { open: "[", close: "]" },
      { open: "(", close: ")" },
      { open: '"', close: '"' },
      { open: "'", close: "'" },
    ],
  });
}
