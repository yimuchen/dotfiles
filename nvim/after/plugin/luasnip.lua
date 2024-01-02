local ls = require("luasnip")
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node

ls.add_snippets("python", {
  -- trigger is `fn`, second argument to snippet-constructor are the nodes to
  -- insert into the buffer on expansion.
  ls.snippet("__main__", { t('if __name__ == "__main__":'), t("  "), i(0) }),
})
