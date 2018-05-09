__author__  = "Zhu ZhiDong"
__version__ = "1.0"
#
# SysListView32 item number, starting from zero. Relative mapping to Absolute.
#
def GenItemList(start):
    start = int(start)
    return [start + i for i in range(1, 30)]

# -------------------------------- End of file --------------------------------
