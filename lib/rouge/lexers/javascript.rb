module Rouge
  module Lexers
    JavascriptLexer = RegexLexer.create do
      option :debug, true

      name 'javascript'
      aliases 'js'

      lexer :comments_and_whitespace do
        rule /\s+/, 'Text'
        rule /<!--/, 'Comment' # really...?
        rule %r(//.*?\n), 'Comment.Single'
        rule %r(/\*.*?\*/), 'Comment.Multiline'
      end

      lexer :slash_starts_regex do
        mixin :comments_and_whitespace
        rule %r(
          /(\\.|[^[/\\\n]|\[(\\.|[^\]\\\n])*])+/ # a nonempty regex
          (?:[gim]+\b|\B) # regex flags
        )x, 'Literal.String.Regex'

        # if it's not matched by the above r.e., it's not
        # a valid expression, so we use :bad_regex to eat until the
        # end of the line.
        rule %r(/), 'Literal.String.Regex', :bad_regex
        rule //, 'Text', :pop!

        lexer :bad_regex do
          rule /[^\n]+/, 'Error', :pop!
        end
      end

      keywords = %w(
        for in while do break return continue switch case default if else
        throw try catch finally new delete typeof instanceof void this
      ).join('|')

      declarations = %w(var let with function).join('|')

      reserved = %w(
        abstract boolean byte char class const debugger double enum export
        extends final float goto implements import int interface long
        native package private protected public short static super
        synchronized throws transient volatile
      ).join('|')

      constants = %w(true false null NaN Infinity undefined).join('|')

      builtins = %w(
        Array Boolean Date Error Function Math netscape
        Number Object Packages RegExp String sun decodeURI
        decodeURIComponent encodeURI encodeURIComponent
        Error eval isFinite isNaN parseFloat parseInt document this
        window
      ).join('|')

      lexer :root do
        rule %r(^(?=\s|/|<!--)), 'Text', :slash_starts_regex
        mixin :comments_and_whitespace
        rule %r(\+\+|--|~|&&|\?|\|\||\\(?=\n)|<<|>>>?|===|!==),
          'Operator', :slash_starts_regex
        rule %r([-<>+*%&|\^/!=]=?), 'Operator', :slash_starts_regex
        rule /[{(\[;,]/, 'Punctuation', :slash_starts_regex
        rule /[})\].]/, 'Punctuation'
        rule /(?:#{keywords})\b/, 'Keyword', :slash_starts_regex
        rule /(?:#{declarations})\b/, 'Keyword.Declaration', :slash_starts_regex
        rule /(?:#{reserved})\b/, 'Keyword.Reserved'
        rule /(?:#{constants})\b/, 'Keyword.Constant'
        rule /(?:#{builtins})\b/, 'Name.Builtin'
        rule /[$a-zA-Z_][a-zA-Z0-9_]*/, 'Name.Other'

        rule /[0-9][0-9]*\.[0-9]+([eE][0-9]+)?[fd]?/, 'Number.Float'
        rule /0x[0-9a-fA-F]+/, 'Number.Hex'
        rule /[0-9]+/, 'Number.Integer'
        rule /"(\\\\|\\"|[^"])*"/, 'Literal.String.Double'
        rule /'(\\\\|\\'|[^'])*'/, 'Literal.String.Single'
      end

      mixin :root
    end
  end
end