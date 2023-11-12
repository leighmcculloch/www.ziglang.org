# ziglang.org

Website for [Zig](https://github.com/ziglang/zig)

## Running the development server

```
zig build serve
```

## Writing a translation

Translations rely on three main conventions:

1. The presence of the corresponding language in `config.zon`
2. The `themes/ziglang-original/i18n` directory, which contains translations
   for menu elements, the download page and a few other miscelanneous strings.
3. In `content/`, the presence of markdown files for the specific language
   you're translating to.

Let's say that you're working on a Japanese translation. The
[two-letter ISO code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)
for Japanese is `ja`.

Start by adding the new translation to `config.zon`.

Then copy `content/_index.en.md` to `content/_index.ja.md` and apply a small
change to be able to distinguish the two versions.

Start `zig build serve` (or reload it); at this point you can go in your browser to
`localhost:PORT/ja/` to preview your translation.

Translate all files in `content/` that have a `.en.md` extension, and translate
`themes/ziglang-original/i18n/en.toml` to translate some menu items, the
downloads page, and a few other miscellaneous strings.

Finally, add your translation to `translations/index.md`.

### Getting help

Crafting a translation is not a straight-forward proceess. You have to think
about adaptation, spatial constraints (in the front page especially), and other
Hugo-specific issues that might not be immediately obvious.

Please consider joining one of the Zig communities, where you will be able to
communicate with other contributors and exchange knowledge.

If you prefer asynchronous communication, feel free to open a draft PR and we
will do our best to engage with you pronto.

Keep in mind that it's possible that the current setup doesn't allow you
correctly implement a translation without making ulterior changes to
configuration or how the content is organized. Don't hesitate to reach out for
help to avoid getting stuck in a problem that can't be solved without
larger-scale changes.
