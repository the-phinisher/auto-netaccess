"use strict";

const pupeteer = require("puppeteer");

require("dotenv").config();
const env = process.env;

const removePreviousIP = async (page) => {
  const activeIPCount = env.IPCOUNT;
  const deleteButtons = await page.$$("span.label.label-danger");

  const filteredButtons = [];
  for (const btn of deleteButtons) {
    const text = await page.evaluate((el) => el.textContent.trim(), btn);
    if (text === "Delete") {
      filteredButtons.push(btn);
    }
  }

  if (filteredButtons.length > activeIPCount) {
    for (let i = activeIPCount; i < filteredButtons.length; i++) {
      await Promise.all([
        filteredButtons[i].click(),
        page.waitForNavigation({ waitUntil: "networkidle0" }),
      ]);
    }
  }
};

const main = async () => {
  {
    const browser = await pupeteer.launch();
    const page = await browser.newPage();
    await page.goto("https://netaccess.iitm.ac.in/account/login");
    await page.setViewport({ width: 1080, height: 1024 });
    await page.locator("#username").fill(env.ROLLNO);
    await page.locator("#password").fill(env.PASSWD);
    await page.click("#submit");
    await page.click('a[href="/account/approve"]');
    await page.click("#radios-1");
    await page.click("#approveBtn");
    await removePreviousIP(page);
    await browser.close();
  }
};

main();
