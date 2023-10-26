const express = require('express')
// const ankiToJson = require('anki-to-json')
const ankiToJson = require('./lib').default
const fs = require('fs')git init
const multiparty = require('multiparty')
const app = express()
const port = 3000

app.use(express.json())

app.post('/convert', async (req, res) => {
//  try {
    // const { inputFile } = req.body
    ankiToJson('./bin/file.apkg', './output')

})

app.post('/upload', (req, res) => {
  const form = new multiparty.Form()

  form.parse(req, async (err, fields, files) => {
    if (err) {
      return res.status(500).json({ error: err.message })
    }

    if (files.file && files.file[0]) {
      const uploadedFile = files.file[0]
      console.log(`Upload file: ${uploadedFile.originalFilename}`)

      // Thay đổi đường dẫn và tên tệp lưu vào thư mục
      const outputDirectory = './output1'// Thư mục đích để lưu tệp
      const newFileName = 'input.apkg' // Tên mới cho tệp

      const outputFilePath = `${outputDirectory}/${newFileName}`

      // Di chuyển tệp từ vị trí tạm thời đến thư mục đích và đổi tên tệp
      fs.rename(uploadedFile.path, outputFilePath, (err) => {
        if (err) {
          return res.status(500).json({ error: err.message })
        }
        res.status(200).json({ message: 'File uploaded and renamed successfully' })

      })
    } else {
      return res.status(400).json({ error: 'File not provided' })
    }
  })
})

app.get('/files', (req, res) => {
  const outputDirectory = './output/media'

  fs.readdir(outputDirectory, (err, files) => {
    if (err) {
      res.status(500).json({ error: err.message })
    } else {
      res.json({ files })
    }
  })
})

app.get('/remove', (req, res) => {
  fs.rmdir('./output', { recursive: true }, (err) => {
    if (err) {
      console.error(err)
    } else {
      console.log('Directory deleted successfully')
    }
  })
})

app.get('/files/:filename', (req, res) => {
  const fs = require('fs')
  const outputDirectory = './output/media'
  const filename = req.params.filename
  const filePath = `${outputDirectory}/${filename}`

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.status(500).json({ error: err.message })
    } else {
      res.setHeader('Content-Disposition', `attachment; filename="${filename}"`)
      res.setHeader('Content-Type', 'application/octet-stream')
      res.send(data)
    }
  })
})

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`)
})
