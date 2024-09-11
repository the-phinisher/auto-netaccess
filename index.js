const pupeteer = require("puppeteer");

require("dotenv").config();
const env = process.env;

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
    await browser.close();
  }
};

main();
