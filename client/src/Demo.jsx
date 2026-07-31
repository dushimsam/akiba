import React, { useEffect, useState } from 'react'
import './Demo.css'
import { transactionAPI, healthCheck } from './api'

const SEED = [
  { id: 'tx1', name: 'Amara Okafor', type: 'received', method: 'Mobile Money', amount: 45000, date: '2026-07-31T09:12:00Z' },
  { id: 'tx2', name: 'Airtime top-up', type: 'sent', method: 'MTN', amount: 2000, date: '2026-07-30T18:40:00Z' },
  { id: 'tx3', name: 'Zawadi Mwangi', type: 'sent', method: 'Bank transfer', amount: 128500, date: '2026-07-30T11:05:00Z' },
]

function formatAmount(v) {
  return new Intl.NumberFormat('en-RW', { maximumFractionDigits: 0 }).format(v)
}

function formatDate(iso) {
  const d = new Date(iso)
  const today = new Date()
  const time = d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' })
  if (d.toDateString() === today.toDateString()) return `Today, ${time}`
  return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' }) + `, ${time}`
}

let idCounter = 100

function Demo() {
  const [transactions, setTransactions] = useState(SEED)
  const [balance, setBalance] = useState(842500)
  const [connected, setConnected] = useState(null)
  const [recipient, setRecipient] = useState('')
  const [amount, setAmount] = useState('')
  const [method, setMethod] = useState('Mobile Money')
  const [flash, setFlash] = useState('')

  useEffect(() => {
    let active = true
    healthCheck()
      .then(() => active && setConnected(true))
      .catch(() => active && setConnected(false))
    transactionAPI
      .getTransactions('me')
      .then((res) => {
        const data = res?.data?.transactions ?? res?.data
        if (active && Array.isArray(data) && data.length) setTransactions(data)
      })
      .catch(() => {})
    return () => { active = false }
  }, [])

  function handleSend(e) {
    e.preventDefault()
    const value = Number(amount)
    if (!recipient.trim() || !value || value <= 0) return
    if (value > balance) { setFlash('Not enough balance for that transfer.'); return }

    const tx = {
      id: `local-${idCounter++}`,
      name: recipient.trim(),
      type: 'sent',
      method,
      amount: value,
      date: new Date().toISOString(),
    }
    setTransactions((prev) => [tx, ...prev])
    setBalance((b) => b - value)
    setFlash(`Sent RWF ${formatAmount(value)} to ${tx.name}.`)
    setRecipient('')
    setAmount('')

    // Fire-and-forget to the real API if it's available; UI already updated.
    transactionAPI.createTransaction(tx).catch(() => {})
  }

  return (
    <div className="demo">
      <div className="demo-left">
        <div className="demo-topline">
          <span className="demo-account">Grace N. · ·····&thinsp;4092</span>
          <span className={connected === false ? 'demo-status off' : 'demo-status'}>
            {connected === null ? 'Checking…' : connected ? 'Live' : 'Demo mode'}
          </span>
        </div>

        <span className="demo-balance-label">Available balance</span>
        <div className="demo-balance">
          <span className="demo-cur">RWF</span> {formatAmount(balance)}
        </div>

        <form className="demo-form" onSubmit={handleSend}>
          <label>
            <span>Send to</span>
            <input
              type="text"
              placeholder="Name or number"
              value={recipient}
              onChange={(e) => setRecipient(e.target.value)}
            />
          </label>
          <div className="demo-form-row">
            <label>
              <span>Amount (RWF)</span>
              <input
                type="number"
                min="1"
                placeholder="0"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
              />
            </label>
            <label>
              <span>Via</span>
              <select value={method} onChange={(e) => setMethod(e.target.value)}>
                <option>Mobile Money</option>
                <option>Bank transfer</option>
                <option>Airtime</option>
              </select>
            </label>
          </div>
          <button type="submit" className="demo-send">Send money</button>
          {flash && <p className="demo-flash">{flash}</p>}
        </form>
      </div>

      <div className="demo-right">
        <div className="demo-right-head">Recent activity</div>
        <ul className="demo-ledger">
          {transactions.map((t) => (
            <li key={t.id}>
              <div className="demo-row-main">
                <span className="demo-row-name">{t.name}</span>
                <span className="demo-row-meta">{t.method} · {formatDate(t.date)}</span>
              </div>
              <span className={t.type === 'received' ? 'demo-amt in' : 'demo-amt out'}>
                {t.type === 'received' ? '+' : '−'}{formatAmount(t.amount)}
              </span>
            </li>
          ))}
        </ul>
      </div>
    </div>
  )
}

export default Demo
