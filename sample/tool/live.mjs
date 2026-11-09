// 线上 Pages 冒烟检查：页面加载、默认生成、切换样例、无控制台错误和失败请求
// 用法：npm run live [-- <url>]，默认检查 https://venshine.github.io/json2model/
import { chromium } from 'playwright-core';

const url = process.argv[2] ?? 'https://venshine.github.io/json2model/';
const browser = await chromium.launch({ channel: 'chrome', headless: true });
const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
const errors = [];
page.on('pageerror', (e) => errors.push(String(e)));
page.on('console', (m) => m.type() === 'error' && errors.push(m.text()));
page.on('response', (r) => r.status() >= 400 && errors.push(`${r.status()} ${r.url()}`));

await page.goto(url);
await page.waitForSelector('flt-semantics[role="button"]', { timeout: 60000 });
await page.waitForTimeout(1000);
const text = () => page.$$eval('flt-semantics', (els) => els.map((e) => (e.getAttribute('aria-label') ?? '') + ' ' + e.textContent).join('\n'));

const checks = [];
checks.push(['title', (await page.title()) === 'json2model Playground']);
checks.push(['default preset generates valid Dart', (await text()).includes('Valid Dart') && (await text()).includes('2 classes · 9 fields')]);
await page.locator('flt-semantics[role="button"]', { hasText: 'Nested' }).first().click();
await page.waitForTimeout(800);
checks.push(['Nested -> 4 classes', (await text()).includes('4 classes · 12 fields')]);
await browser.close();

for (const [name, ok] of checks) console.log(ok ? 'PASS' : 'FAIL', name);
console.log('errors:', JSON.stringify(errors));
process.exit(checks.every(([, ok]) => ok) && errors.length === 0 ? 0 : 1);
