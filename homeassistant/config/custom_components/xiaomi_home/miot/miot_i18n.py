# -*- coding: utf-8 -*-
"""
Copyright (C) 2024 Xiaomi Corporation.

The ownership and intellectual property rights of Xiaomi Home Assistant
Integration and related Xiaomi cloud service API interface provided under this
license, including source code and object code (collectively, "Licensed Work"),
are owned by Xiaomi. Subject to the terms and conditions of this License, Xiaomi
hereby grants you a personal, limited, non-exclusive, non-transferable,
non-sublicensable, and royalty-free license to reproduce, use, modify, and
distribute the Licensed Work only for your use of Home Assistant for
non-commercial purposes. For the avoidance of doubt, Xiaomi does not authorize
you to use the Licensed Work for any other purpose, including but not limited
to use Licensed Work to develop applications (APP), Web services, and other
forms of software.

You may reproduce and distribute copies of the Licensed Work, with or without
modifications, whether in source or object form, provided that you must give
any other recipients of the Licensed Work a copy of this License and retain all
copyright and disclaimers.

Xiaomi provides the Licensed Work on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied, including, without
limitation, any warranties, undertakes, or conditions of TITLE, NO ERROR OR
OMISSION, CONTINUITY, RELIABILITY, NON-INFRINGEMENT, MERCHANTABILITY, or
FITNESS FOR A PARTICULAR PURPOSE. In any event, you are solely responsible
for any direct, indirect, special, incidental, or consequential damages or
losses arising from the use or inability to use the Licensed Work.

Xiaomi reserves all rights not expressly granted to you in this License.
Except for the rights expressly granted by Xiaomi under this License, Xiaomi
does not authorize you in any form to use the trademarks, copyrights, or other
forms of intellectual property rights of Xiaomi and its affiliates, including,
without limitation, without obtaining other written permission from Xiaomi, you
shall not use "Xiaomi", "Mijia" and other words related to Xiaomi or words that
may make the public associate with Xiaomi in any form to publicize or promote
the software or hardware devices that use the Licensed Work.

Xiaomi has the right to immediately terminate all your authorization under this
License in the event:
1. You assert patent invalidation, litigation, or other claims against patents
or other intellectual property rights of Xiaomi or its affiliates; or,
2. You make, have made, manufacture, sell, or offer to sell products that knock
off Xiaomi or its affiliates' products.

MIoT internationalization translation.
"""
import asyncio
import logging
import os
from typing import Optional, Union

# pylint: disable=relative-beyond-top-level
from .common import load_json_file

_LOGGER = logging.getLogger(__name__)


class MIoTI18n:
    """MIoT Internationalization Translation.
    Translate by Copilot, which does not guarantee the accuracy of the 
    translation. If there is a problem with the translation, please submit 
    the ISSUE feedback. After the review, we will modify it as soon as possible.
    """
    _main_loop: asyncio.AbstractEventLoop
    _lang: str
    _data: dict

    def __init__(
        self, lang: str, loop: Optional[asyncio.AbstractEventLoop]
    ) -> None:
        self._main_loop = loop or asyncio.get_event_loop()
        self._lang = lang
        self._data = {}

    async def init_async(self) -> None:
        if self._data:
            return
        data = None
        self._data = {}
        try:
            data = await self._main_loop.run_in_executor(
                None, load_json_file,
                os.path.join(
                    os.path.dirname(os.path.abspath(__file__)),
                    f'i18n/{self._lang}.json'))
        except Exception as err:  # pylint: disable=broad-exception-caught
            _LOGGER.error('load file error, %s', err)
            return
        # Check if the file is a valid JSON file
        if not isinstance(data, dict):
            _LOGGER.error('valid file, %s', data)
            return
        self._data = data

    async def deinit_async(self) -> None:
        self._data = {}

    def translate(
        self, key: str, replace: Optional[dict[str, str]] = None
    ) -> Union[str, dict, None]:
        result = self._data
        for item in key.split('.'):
            if item not in result:
                return None
            result = result[item]
        if isinstance(result, str) and replace:
            for k, v in replace.items():
                result = result.replace('{'+k+'}', str(v))
        return result or None
