#!/usr/bin/env python3
"""Render Reveal.js HTML slides to PNG images using pyppeteer.

Usage:
  python tools/render_slides_pyppeteer.py path/to/reveal.html output_dir

Notes:
  - Installs a bundled Chromium on first run (pyppeteer). 인터넷 연결 필요.
  - Outputs files: output_dir/slide_01.png, slide_02.png, ...
"""
import asyncio
import sys
import os
from pyppeteer import launch


async def render(html_path, out_dir):
    if not os.path.exists(html_path):
        raise SystemExit(f"File not found: {html_path}")
    os.makedirs(out_dir, exist_ok=True)
    browser = await launch(args=['--no-sandbox'])
    page = await browser.newPage()
    file_url = 'file:///' + os.path.abspath(html_path).replace('\\', '/')
    await page.goto(file_url)

    # wait for Reveal to initialize
    await page.waitForFunction('window.Reveal && Reveal.isReady')

    # get total slides
    total = await page.evaluate('''() => {
        const slides = Array.from( document.querySelectorAll('.reveal .slides > section') );
        return slides.length;
    }''')

    for i in range(total):
        # navigate to slide index
        await page.evaluate(f'() => {{ Reveal.slide({i}, 0, 0); }}')
        await asyncio.sleep(0.3)
        out_name = os.path.join(out_dir, f'slide_{i+1:02d}.png')
        await page.screenshot({'path': out_name, 'fullPage': True})
        print('Saved', out_name)

    await browser.close()


def main():
    if len(sys.argv) < 3:
        print('Usage: python tools/render_slides_pyppeteer.py path/to/reveal.html output_dir')
        sys.exit(1)
    html = sys.argv[1]
    out = sys.argv[2]
    asyncio.get_event_loop().run_until_complete(render(html, out))


if __name__ == '__main__':
    main()
