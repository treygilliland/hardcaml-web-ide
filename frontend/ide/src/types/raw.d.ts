declare module "*.ml?raw" {
  const content: string;
  export default content;
}

declare module "*.mli?raw" {
  const content: string;
  export default content;
}

declare module "*.txt?raw" {
  const content: string;
  export default content;
}

declare module "@hardcaml-examples/examples/*/circuit.ml?raw" {
  const content: string;
  export default content;
}

declare module "@hardcaml-examples/examples/*/circuit.mli?raw" {
  const content: string;
  export default content;
}

declare module "@hardcaml-examples/examples/*/test.ml?raw" {
  const content: string;
  export default content;
}

declare module "@hardcaml-examples/examples/*/input.txt?raw" {
  const content: string;
  export default content;
}

declare module "@hardcaml-examples/build-cache/lib/n2t_chips/*.ml?raw" {
  const content: string;
  export default content;
}

declare module "@hardcaml-examples/build-cache/lib/n2t_chips/*.mli?raw" {
  const content: string;
  export default content;
}
