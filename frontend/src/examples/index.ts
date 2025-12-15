/**
 * Example/Exercise type definitions for HardCaml Web IDE
 * 
 * Examples are organized as exercises that students can work through.
 * Each example contains:
 * - circuit: The main implementation file (circuit.ml)
 * - interface: The module interface (circuit.mli)
 * - test: The test harness (test.ml)
 */

export interface HardcamlExample {
  /** Display name for the example */
  name: string;
  /** Short description of what the exercise teaches */
  description?: string;
  /** Difficulty level for students */
  difficulty?: 'beginner' | 'intermediate' | 'advanced';
  /** The main circuit implementation (circuit.ml) */
  circuit: string;
  /** The module interface (circuit.mli) */
  interface: string;
  /** The test harness (test.ml) */
  test: string;
}

export type ExampleKey = 'counter';

// Import all examples
import { counterExample } from './counter';

/**
 * All available examples in the IDE
 */
export const examples: Record<ExampleKey, HardcamlExample> = {
  counter: counterExample,
};

/**
 * Get list of available example keys for UI dropdowns
 */
export const getExampleKeys = (): ExampleKey[] => {
  return Object.keys(examples) as ExampleKey[];
};

/**
 * Get an example by key, or undefined if not found
 */
export const getExample = (key: string): HardcamlExample | undefined => {
  return examples[key as ExampleKey];
};

