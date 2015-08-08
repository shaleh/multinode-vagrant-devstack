"""
Needed because the jinja2 version is too old for
selectattr(foo, equalto, value)
"""

class FilterModule(object):
    def filters(self):
        return {
            'byattr': lambda lst, k, v: [i for i in lst if i[k] == v],
            'lookup': lambda d, k: d[k]
        }
