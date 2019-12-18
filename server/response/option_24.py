# DHCPy6d DHCPv6 Daemon
#
# Copyright (C) 2009-2019 Henri Wahl <h.wahl@ifw-dresden.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA

from ..config import cfg
from ..helpers import (build_option,
                       convert_dns_to_binary)


# Option 24 Domain Search List
def build(response_ascii):
    converted_domain_search_list = ''
    for d in cfg.DOMAIN_SEARCH_LIST:
        converted_domain_search_list += convert_dns_to_binary(d)
    response_ascii += build_option(24, converted_domain_search_list)
