import {includeIgnoreFile} from "@eslint/compat"
import pluginJS from "@eslint/js"
import type {Linter} from "eslint"
import globals from "globals"
import {join} from "node:path"
import tseslint from "typescript-eslint"

export default [
  includeIgnoreFile(join(import.meta.dirname, ".gitignore")),
  pluginJS.configs.recommended,
  ...(tseslint.configs.strict as Linter.Config[]),
  {
    languageOptions: {globals: globals.node},
    rules: {
      "@typescript-eslint/no-unused-vars": "warn",
      "dot-notation": "warn",
      eqeqeq: "warn",
      "max-depth": ["warn", 3],
      "no-console": "warn",
      "prefer-const": "warn",
    },
  },
] satisfies Linter.Config[]
