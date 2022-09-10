from qutebrowser.api import interceptor  # for youtube adblocking

config.load_autoconfig(False)

c.fileselect.handler = "external"

c.content.blocking.method = "adblock"
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://easylist-downloads.adblockplus.org/easylistdutch.txt",
    "https://easylist-downloads.adblockplus.org/abp-filters-anti-cv.txt",
    "https://www.i-dont-care-about-cookies.eu/abp/",
    "https://secure.fanboy.co.nz/fanboy-cookiemonster.txt",
]

# getting rid of annoying cookie bars
# see https://www.reddit.com/r/qutebrowser/comments/mnptey/getting_rid_of_cookie_consent_barspopups/
config.bind(
    "e",
    "jseval (function () { "
    + '  var i, elements = document.querySelectorAll("body *");'
    + ""
    + "  for (i = 0; i < elements.length; i++) {"
    + "    var pos = getComputedStyle(elements[i]).position;"
    + '    if (pos === "fixed" || pos == "sticky") {'
    + "      elements[i].parentNode.removeChild(elements[i]);"
    + "    }"
    + "  }"
    + "})();",
)


# fonts
c.fonts.default_family = '"Source Code Pro"'

# initiate editor with custom vimrc
# c.editor.command = ['urxvt', '-name', 'qute-editor', '-e','vim', '-S', '~/.config/qutebrowser/editor.vimrc', '{}']
# c.editor.command = ['urxvt', '-name', 'qute-editor', '-e','vim', '-S', '{}']
# c.editor.command = ["emacsclient", "-c", " {file}"]
# c.editor.command = ['urxvt', '-name', 'qute-editor', '-e','vim', '-S', '{file}']
c.editor.command = ["urxvt", "-e", "vim", "{}"]


###darkmode
# # # # # https://old.reddit.com/r/qutebrowser/comments/jdnqbp/yet_another_dark_mode_post/
c.colors.webpage.darkmode.enabled = True
# dark/night mode
c.colors.webpage.darkmode.policy.images = "smart"
c.colors.webpage.bg = "black"

# custom commands

# userscripts
config.bind("zf", "spawn --userscript open-url-in-firefox")
config.bind("zF", "spawn --userscript open-url-in-firefox-private")
config.bind("zg", "spawn --userscript ddg-to-google")
config.bind("zy", "spawn --userscript google-results-year")
config.bind("zv", "spawn --userscript readability")
config.bind("ze", "spawn --userscript searchbar-command")
config.bind("zs", "spawn --userscript redirect-pbtynpj")
# config.bind('zm', 'spawn --userscript archive-url')
config.bind("zm", "spawn --userscript mpv-url")
config.bind("zum", "spawn --userscript undo-archive-url")
config.bind("zx", "spawn --userscript sx-close-consent-bar")
config.bind("zr", "spawn --userscript reddit-to-old")
config.bind("za", "spawn --userscript arxiv-to-ar5iv")
# config.bind('zz', 'spawn --userscript readability-js')
config.bind("zz", "spawn --userscript qute-cookie-block")
config.bind("yo", "yank inline [{url}[{title}]]")


# set marks
config.unbind("m")
config.bind("mm", "set-mark m")
config.bind("mn", "set-mark n")
config.bind("ma", "set-mark a")

# other
config.bind("zo", "download-open")
# config.bind('e', 'open-editor')
config.bind("cs", "config-source")
config.bind("tg", "tab-give")
config.bind("<Ctrl-n>", "config-cycle statusbar.hide")
config.bind("U", "tab-focus last")

# # search engines
# # c.url.searchengines = {"DEFAULT":'https://google.com/search?hl=en&q={}'}
c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}&k1=-1&kc=-1&kaj=m&kak=-1&kax=-1&kaq=-1&kap=-1&kao=-1&kau=-1&kae=c&kt=p&ks=l&km=l&ko=d&k18=1&kg=g",  # light/bright
    # "DEFAULT": "https://www.google.com/search?hl=en&q={}",
    #     # "DEFAULT":'https://duckduckgo.com/?q={}&kae=d&kau=-1&kao=-1&kap=-1&kaq=-1&kax=-1&kak=-1&ko=-1', # dark
    #     # "DEFAULT":'https://duckduckgo.com/?q={}&kae=b&kau=-1&kao=-1&kap=-1&kaq=-1&kax=-1&kak=-1&ko=-1', # light/bright
    "np": "https://search.nixos.org/packages?channel=21.05&from=0&size=50&sort=relevance&type=packages&query={}",
    #     "no": "https://search.nixos.org/options?query={}&from=0&size=30&sort=relevance&channel=unstable",
    #     "hg": "https://hoogle.haskell.org/?hoogle={}",
    #     "gl": "http://gen.lib.rus.ec/search.php?req={}",
    #     "yc": "https://www.google.com/search?hl=en&q=site%3Anews.ycombinator.com%20{}",  # hacker news
    #     "rr": "https://www.google.com/search?hl=en&q=site%3Areddit.com%20{}",
    #     "sh": "http://symbolhound.com/?q={}",
}

## general settings

# page displayed when opening new tab
c.url.default_page = "about:blank"
c.url.start_pages = "about:blank"

# dowlnoad directory
c.downloads.location.directory = "~/downloads"

# hint characters
c.hints.chars = "arstneio"

# height of completion bar
c.completion.height = "30%"

c.tabs.show = "multiple"

# cookies settings
c.content.cookies.store = False
# c.content.cookies.accept = 'never'

# disallow notifications
# c.content.notifications.enabled = False

### per-domain settings, see http://qutebrowser.org/doc/help/configuring.html

# with config.pattern('*.stackexchange.com') as sx:
#     sx.content.cookies.store = True # NOTE per-domain settings not available for "store", only fr "accept"

# https://git.maximewack.com/maxx/dotfiles/src/commit/c6611e7ef3ab93a712b8e37e784fed1b38fc1174/.config/qutebrowser/config.py

c.completion.cmd_history_max_items = -1
c.completion.web_history.max_items = -1

# youtube ad blocking
# source: https://old.reddit.com/r/qutebrowser/comments/jut9ng/why_i_use_qutebrowser_and_how_i_configure_it/ 06:20
def filter_yt(info: interceptor.Request):
    """Block the given request if necessary."""
    url = info.request_url
    if (
        url.host() == "www.youtube.com"
        and url.path() == "/get_video_info"
        and "&adformat=" in url.query()
    ):
        info.block()


interceptor.register(filter_yt)

# enable readline keybindings in insert mode
# source: https://gist.github.com/Gavinok/f9c310a66576dc00329dd7bef2b122a1
config.bind("<Ctrl-h>", "fake-key <Backspace>", "insert")
config.bind("<Ctrl-a>", "fake-key <Home>", "insert")
config.bind("<Ctrl-e>", "fake-key <End>", "insert")
config.bind("<Ctrl-b>", "fake-key <Left>", "insert")
config.bind("<Mod1-b>", "fake-key <Ctrl-Left>", "insert")
config.bind("<Ctrl-f>", "fake-key <Right>", "insert")
config.bind("<Mod1-f>", "fake-key <Ctrl-Right>", "insert")
config.bind("<Ctrl-p>", "fake-key <Up>", "insert")
config.bind("<Ctrl-n>", "fake-key <Down>", "insert")
config.bind("<Mod1-d>", "fake-key <Ctrl-Delete>", "insert")
config.bind("<Ctrl-d>", "fake-key <Delete>", "insert")
config.bind("<Ctrl-w>", "fake-key <Ctrl-Backspace>", "insert")
config.bind("<Ctrl-u>", "fake-key <Shift-Home><Delete>", "insert")
config.bind("<Ctrl-k>", "fake-key <Shift-End><Delete>", "insert")
config.bind("<Ctrl-x><Ctrl-e>", "open-editor", "insert")
