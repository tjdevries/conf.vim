# ============================================================================
# FILE: menu.py
# AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
#         TJ DeVries <devries.timothyj at gmail.com>
# License: MIT license
# ============================================================================

from .base import Base


class Source(Base):
    def __init__(self, vim):
        Base.__init__(self, vim)

        self.name = 'conf'
        self.kind = 'command'

        # self.matchers = []
        # self.sorters = []

        # self.vars = {
        #     'config': ''
        # }

    def on_init(self, context):
        pass

    def gather_candidates(self, context):
        args = context['args'][0]
        name = args.split('#')[0]

        self.debug(args)

        config_view = self.vim.call(args + '#view')
        self.debug(config_view)
        self.debug(config_view.keys())

        lines = []
        for area in sorted(config_view.keys()):
            for setting in sorted(config_view[area].keys()):
                setting_dict = config_view[area][setting]

                self.debug('{} {} {}'.format(
                    area,
                    setting,
                    setting_dict
                ))

                setting_name = '{}.{}.{}'.format(name, area, setting)
                padding = (50 - len(setting_name)) * ' '
                description = ''
                if 'description' in setting_dict.keys():
                    description = setting_dict['description']

                # TODO: Provide a more clear error message that stays in the message window.
                command = """
                noautocmd try |
                call {}#set_prompt("{}", "{}") |
                catch |
                echom "Error setting value" |
                echom v:exception |
                endtry
                """.format(
                    args,
                    area,
                    setting,
                )
                self.debug('Adding command: ' + command)

                lines.append({
                    'word': setting_name + padding + description,
                    'kind': 'command',
                    'action__command': command
                })


        return lines

    # TODO: Define a highlighting pattern to make things prettier
