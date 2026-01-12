import { useState } from 'react';
import { OcamlEditor, OutputPanel, useCompiler } from '@hardcaml/ui';

interface PlaygroundProps {
  title?: string;
  initialCode: string;
  interfaceCode?: string;
  testCode: string;
  apiBase?: string;
}

const DEFAULT_INTERFACE = `open! Hardcaml

module I : sig
  type 'a t = { clock : 'a; clear : 'a; enable : 'a }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t = { out : 'a [@bits 8] }
  [@@deriving hardcaml]
end

val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
`;

export function Playground({
  title = 'Try it yourself',
  initialCode,
  interfaceCode = DEFAULT_INTERFACE,
  testCode,
  apiBase = import.meta.env.PUBLIC_API_BASE_URL || 'https://hardcaml.tg3.dev',
}: PlaygroundProps) {
  const [code, setCode] = useState(initialCode);
  const compiler = useCompiler({ apiBase });

  const handleRun = () => {
    compiler.compile({
      circuit: code,
      interface: interfaceCode,
      test: testCode,
    });
  };

  const handleOpenInIDE = () => {
    // Encode the code and open in full IDE
    const encoded = btoa(encodeURIComponent(code));
    window.open(`${apiBase}?code=${encoded}`, '_blank');
  };

  return (
    <div className="playground-container">
      <div className="playground-header">
        <span className="playground-title">{title}</span>
        <div className="playground-actions">
          <button
            className="playground-btn playground-btn-secondary"
            onClick={handleOpenInIDE}
          >
            Open in IDE ↗
          </button>
          <button
            className="playground-btn"
            onClick={handleRun}
            disabled={compiler.loading}
          >
            {compiler.loading ? '⏳ Running...' : '▶ Run'}
          </button>
        </div>
      </div>
      <div className="playground-content">
        <div className="playground-editor">
          <OcamlEditor
            value={code}
            onChange={setCode}
            height="400px"
          />
        </div>
        <div className="playground-output">
          <OutputPanel result={compiler.result} />
        </div>
      </div>
    </div>
  );
}

export default Playground;
