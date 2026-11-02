import React from 'react'
import ReactDOM from 'react-dom/client'
import { MainWindow } from './renderer/main/MainWindow'
import './styles/index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <MainWindow />
  </React.StrictMode>,
)
