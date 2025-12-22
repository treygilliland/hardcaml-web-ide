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

declare module "@hardcaml/examples/*/circuit.ml?raw" {
  const content: string;
  export default content;
}

declare module "@hardcaml/examples/*/circuit.mli?raw" {
  const content: string;
  export default content;
}

declare module "@hardcaml/examples/*/test.ml?raw" {
  const content: string;
  export default content;
}

declare module "@hardcaml/examples/*/input.txt?raw" {
  const content: string;
  export default content;
}
