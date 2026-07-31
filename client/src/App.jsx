import React, { useState } from 'react'
import './App.css'
import Demo from './Demo'

const FEATURES = [
  {
    title: 'Send in seconds',
    body: 'Move money to any mobile wallet or bank account across the region, with no hidden fees on transfers.',
  },
  {
    title: 'Pay every bill',
    body: 'Electricity, water, airtime, subscriptions — settle them all from one place and keep the receipts.',
  },
  {
    title: 'Save as you go',
    body: 'Round up your spending or set aside a little each week. Akiba means savings, and we mean it.',
  },
]

const STEPS = [
  { n: '01', title: 'Create your account', body: 'Sign up with your phone number in under two minutes.' },
  { n: '02', title: 'Add your money', body: 'Top up from a mobile wallet, card, or bank transfer.' },
  { n: '03', title: 'Start moving', body: 'Send, pay, and save — from your phone, wherever you are.' },
]

function App() {
  const [menuOpen, setMenuOpen] = useState(false)

  return (
    <div className="site">
      <header className="nav">
        <div className="nav-inner">
          <a className="wordmark" href="#top">Akiba</a>

          <nav className={`nav-links ${menuOpen ? 'open' : ''}`}>
            <a href="#features">Features</a>
            <a href="#how">How it works</a>
            <a href="#demo">Demo</a>
            <a href="#help">Help</a>
          </nav>

          <div className="nav-cta">
            <a className="text-link" href="#signin">Sign in</a>
            <a className="btn btn-solid" href="#get">Get the app</a>
          </div>

          <button
            className="nav-toggle"
            aria-label="Toggle menu"
            onClick={() => setMenuOpen((v) => !v)}
          >
            <span /><span /><span />
          </button>
        </div>
      </header>

      <main id="top">
        <section className="hero">
          <div className="hero-copy">
            <p className="eyebrow">Mobile money, done right</p>
            <h1>Money that moves as fast as you do.</h1>
            <p className="lede">
              Send, pay, and save across mobile wallets and banks — all from one
              simple app built for everyday life in Africa.
            </p>
            <div className="hero-actions">
              <a className="btn btn-solid btn-lg" href="#get">Get started</a>
              <a className="btn btn-ghost btn-lg" href="#how">See how it works</a>
            </div>
            <p className="hero-fineprint">Free to sign up · No monthly fees</p>
          </div>

          <div className="hero-visual" aria-hidden="true">
            <div className="phone">
              <div className="phone-notch" />
              <div className="phone-screen">
                <span className="phone-label">Available balance</span>
                <span className="phone-balance">RWF 842,500</span>
                <div className="phone-row">
                  <span>Amara Okafor</span>
                  <span className="in">+45,000</span>
                </div>
                <div className="phone-row">
                  <span>Electricity bill</span>
                  <span>−15,750</span>
                </div>
                <div className="phone-row">
                  <span>Kwame Mensah</span>
                  <span className="in">+60,000</span>
                </div>
                <div className="phone-cta">Send money</div>
              </div>
            </div>
          </div>
        </section>

        <section className="stats">
          <div><strong>2M+</strong><span>people paid</span></div>
          <div><strong>12</strong><span>countries</span></div>
          <div><strong>&lt;10s</strong><span>average transfer</span></div>
          <div><strong>0</strong><span>hidden fees</span></div>
        </section>

        <section id="features" className="features">
          <div className="section-head">
            <h2>Everything your money needs to do</h2>
            <p>One account for sending, paying, and saving — without the friction.</p>
          </div>
          <div className="feature-grid">
            {FEATURES.map((f) => (
              <article key={f.title} className="feature">
                <h3>{f.title}</h3>
                <p>{f.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section id="how" className="how">
          <div className="section-head">
            <h2>Up and running in minutes</h2>
          </div>
          <ol className="steps">
            {STEPS.map((s) => (
              <li key={s.n}>
                <span className="step-n">{s.n}</span>
                <div>
                  <h3>{s.title}</h3>
                  <p>{s.body}</p>
                </div>
              </li>
            ))}
          </ol>
        </section>

        <section id="demo" className="demo-section">
          <div className="section-head">
            <h2>See it in action</h2>
            <p>Send a payment and watch your balance and activity update — right here.</p>
          </div>
          <div className="demo-shell">
            <Demo />
          </div>
        </section>

        <section className="cta-band">
          <h2>Your money, in your pocket.</h2>
          <p>Join millions moving money the simple way.</p>
          <a className="btn btn-solid btn-lg" href="#get">Get the app</a>
        </section>
      </main>

      <footer className="footer">
        <div className="footer-inner">
          <div className="footer-brand">
            <span className="wordmark">Akiba</span>
            <p>Mobile money for everyday life.</p>
          </div>
          <div className="footer-cols">
            <div>
              <h4>Product</h4>
              <a href="#features">Send money</a>
              <a href="#features">Pay bills</a>
              <a href="#features">Savings</a>
            </div>
            <div>
              <h4>Company</h4>
              <a href="#business">About</a>
              <a href="#business">Careers</a>
              <a href="#help">Contact</a>
            </div>
            <div>
              <h4>Legal</h4>
              <a href="#legal">Privacy</a>
              <a href="#legal">Terms</a>
            </div>
          </div>
        </div>
        <div className="footer-base">
          <span>© 2026 Akiba. All rights reserved.</span>
        </div>
      </footer>
    </div>
  )
}

export default App
