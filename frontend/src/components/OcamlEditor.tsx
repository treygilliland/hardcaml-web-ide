import { useRef, useEffect } from 'react';
import Editor, { loader, type Monaco } from '@monaco-editor/react';
import type { editor } from 'monaco-editor';

/**
 * Initialize Monaco editor with OCaml language support
 */
let monacoInitialized = false;

const initializeOcamlLanguage = (monaco: Monaco) => {
  if (monacoInitialized) return;
  monacoInitialized = true;

  // Register OCaml language if not already registered
  if (!monaco.languages.getLanguages().some((lang: { id: string }) => lang.id === 'ocaml')) {
    monaco.languages.register({ id: 'ocaml' });
  }

  // Define OCaml syntax highlighting
  monaco.languages.setMonarchTokensProvider('ocaml', {
    keywords: [
      'and', 'as', 'assert', 'asr', 'begin', 'class', 'constraint', 'do', 'done',
      'downto', 'else', 'end', 'exception', 'external', 'false', 'for', 'fun',
      'function', 'functor', 'if', 'in', 'include', 'inherit', 'initializer',
      'land', 'lazy', 'let', 'lor', 'lsl', 'lsr', 'lxor', 'match', 'method',
      'mod', 'module', 'mutable', 'new', 'nonrec', 'object', 'of', 'open', 'or',
      'private', 'rec', 'sig', 'struct', 'then', 'to', 'true', 'try', 'type',
      'val', 'virtual', 'when', 'while', 'with',
    ],
    operators: [
      '=', '>', '<', '!', '~', '?', ':', '==', '<=', '>=', '!=', '&&', '||',
      '++', '--', '+', '-', '*', '/', '&', '|', '^', '%', '<<', '>>', '>>>',
      '+=', '-=', '*=', '/=', '&=', '|=', '^=', '%=', '<<=', '>>=', '>>>=',
    ],
    symbols: /[=><!~?:&|+\-*\/\^%]+/,
    escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,

    tokenizer: {
      root: [
        // Identifiers and keywords
        [/[a-z_$][\w$]*/, {
          cases: {
            '@keywords': 'keyword',
            '@default': 'identifier',
          },
        }],
        [/[A-Z][\w$]*/, 'type.identifier'],

        // Whitespace
        { include: '@whitespace' },

        // Delimiters and operators
        [/[{}()\[\]]/, '@brackets'],
        [/[<>](?!@symbols)/, '@brackets'],
        [/@symbols/, {
          cases: {
            '@operators': 'operator',
            '@default': '',
          },
        }],

        // Numbers
        [/\d*\.\d+([eE][\-+]?\d+)?/, 'number.float'],
        [/0[xX][0-9a-fA-F]+/, 'number.hex'],
        [/\d+/, 'number'],

        // Strings
        [/"([^"\\]|\\.)*$/, 'string.invalid'],
        [/"/, { token: 'string.quote', bracket: '@open', next: '@string' }],

        // Characters
        [/'[^\\']'/, 'string'],
        [/(')(@escapes)(')/, ['string', 'string.escape', 'string']],
        [/'/, 'string.invalid'],
      ],

      comment: [
        [/[^\(*]+/, 'comment'],
        [/\(\*/, 'comment', '@push'],
        [/\*\)/, 'comment', '@pop'],
        [/[\(*]/, 'comment'],
      ],

      string: [
        [/[^\\"]+/, 'string'],
        [/@escapes/, 'string.escape'],
        [/\\./, 'string.escape.invalid'],
        [/"/, { token: 'string.quote', bracket: '@close', next: '@pop' }],
      ],

      whitespace: [
        [/[ \t\r\n]+/, 'white'],
        [/\(\*/, 'comment', '@comment'],
      ],
    },
  });

  // Define OCaml language configuration
  monaco.languages.setLanguageConfiguration('ocaml', {
    comments: {
      blockComment: ['(*', '*)'],
    },
    brackets: [
      ['{', '}'],
      ['[', ']'],
      ['(', ')'],
    ],
    autoClosingPairs: [
      { open: '{', close: '}' },
      { open: '[', close: ']' },
      { open: '(', close: ')' },
      { open: '"', close: '"' },
      { open: "'", close: "'" },
    ],
    surroundingPairs: [
      { open: '{', close: '}' },
      { open: '[', close: ']' },
      { open: '(', close: ')' },
      { open: '"', close: '"' },
      { open: "'", close: "'" },
    ],
  });
};

// Initialize Monaco on load
loader.init().then(initializeOcamlLanguage);

export interface OcamlEditorProps {
  /** Current value of the editor */
  value: string;
  /** Callback when editor content changes */
  onChange: (value: string) => void;
  /** Optional: make the editor read-only */
  readOnly?: boolean;
  /** Optional: height of the editor (default: 100%) */
  height?: string;
  /** Optional: font size (default: 14) */
  fontSize?: number;
  /** Optional: show minimap (default: false) */
  showMinimap?: boolean;
  /** Optional: theme (default: vs-dark) */
  theme?: 'vs-dark' | 'vs-light' | 'hc-black';
}

/**
 * OCaml code editor component using Monaco editor
 * 
 * Features:
 * - OCaml syntax highlighting
 * - OCaml language configuration (comments, brackets, etc.)
 * - Customizable appearance and behavior
 */
export function OcamlEditor({
  value,
  onChange,
  readOnly = false,
  height = '100%',
  fontSize = 14,
  showMinimap = false,
  theme = 'vs-dark',
}: OcamlEditorProps) {
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);

  const handleEditorChange = (newValue: string | undefined) => {
    if (newValue !== undefined) {
      onChange(newValue);
    }
  };

  const handleEditorMount = (editor: editor.IStandaloneCodeEditor) => {
    editorRef.current = editor;
  };

  // Ensure Monaco is initialized with OCaml support
  useEffect(() => {
    loader.init().then(initializeOcamlLanguage);
  }, []);

  return (
    <Editor
      height={height}
      defaultLanguage="ocaml"
      theme={theme}
      value={value}
      onChange={handleEditorChange}
      onMount={handleEditorMount}
      options={{
        minimap: { enabled: showMinimap },
        fontSize,
        lineNumbers: 'on',
        scrollBeyondLastLine: false,
        wordWrap: 'on',
        automaticLayout: true,
        readOnly,
        // Nice defaults for code editing
        tabSize: 2,
        insertSpaces: true,
        renderWhitespace: 'selection',
        bracketPairColorization: { enabled: true },
        guides: {
          bracketPairs: true,
          indentation: true,
        },
      }}
    />
  );
}

export default OcamlEditor;

