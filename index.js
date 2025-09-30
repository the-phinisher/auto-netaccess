"use strict";

const puppeteer = require("puppeteer");

require("dotenv").config({ quiet: true });
const env = process.env;

const removePreviousIP = async (page) => {
  const activeIPCount = env.IPCOUNT;
  const deleteButtons = await page.$$("button.btn.btn-danger");

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
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto("https://netaccess.iitm.ac.in/login");
  await page.setViewport({ width: 1080, height: 1024 });
  await page.locator("#username").fill(env.ROLLNO);
  await page.locator("#password").fill(env.PASSWD);

  // Wait for navigation after clicking submit
  await Promise.all([
    page.waitForNavigation({ waitUntil: "networkidle0" }),
    page.click('button[type="submit"]'),
  ]);

  await page.click('a[href="/approve"]');
  await page.select('#self_duration', '2');

  await page.click('button[type="submit"]'),

  await Promise.all([
    page.waitForNavigation({ waitUntil: "networkidle0" }),
    page.click('#btnAupAccept'),
  ]);

  await removePreviousIP(page);
  await browser.close();
};

main();
