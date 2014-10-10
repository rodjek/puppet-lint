# Public: Check the manifest for unquoted node names and record a warning for
# each instance found.
PuppetLint.new_check(:unquoted_node_name) do
  def check
    node_tokens = tokens.select { |token| token.type == :NODE }
    node_tokens.each do |node|
      node_token_idx = tokens.index(node)
      node_lbrace_tok = tokens[node_token_idx..-1].find { |token| token.type == :LBRACE }
      node_lbrace_idx = tokens.index(node_lbrace_tok)

      tokens[node_token_idx..node_lbrace_idx].select { |token|
        token.type == :NAME
      }.each do |token|
        unless token.value == 'default'
          notify :warning, {
            :message => 'unquoted node name found',
            :line    => token.line,
            :column  => token.column,
            :token   => token,
          }
        end
      end
    end
  end

  def fix(problem)
    problem[:token].type = :SSTRING
  end
end
