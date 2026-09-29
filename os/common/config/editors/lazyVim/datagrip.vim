" DataGrip 2025.1.7.2 / IdeaVim 2.27.1
" The common entry point loads this after common.vim.

" IdeaVim 2.27.1: case conversion requires StringManipulation plugin.
" The last three actions toggle the target style and camelCase.
xmap <leader>rs <Action>(StringManipulation.ToSnakeCase)
xmap <leader>rm <Action>(StringManipulation.ToPascalCase)
xmap <leader>rc <Action>(StringManipulation.ToCamelCase)
xmap <leader>ru <Action>(StringManipulation.ToScreamingSnakeCase)
xmap <leader>rk <Action>(StringManipulation.ToKebabCase)
xmap <leader>r. <Action>(StringManipulation.ToDotStyleAction)
xmap <leader>r<Space> <Action>(osmedile.intellij.stringmanip.styles.ToCamelCaseOrToWordLowercaseAction)
xmap <leader>rt <Action>(osmedile.intellij.stringmanip.ToCamelCaseAction)
