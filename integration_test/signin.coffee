webdriver = require('selenium-webdriver')
driver    = new webdriver.Builder().withCapabilities(webdriver.Capabilities.chrome()).build()
test      = require('selenium-webdriver/testing')

test.describe 'auth with github', ->
  test.it 'should login', ->
    driver.get 'http://localhost:3000'
    driver.findElement(webdriver.By.className('login-link')).click
# driver.get('http://www.google.com')
# driver.findElement(webdriver.By.name('btnK')).click()
    driver.quit()
