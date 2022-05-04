
const modal = document.querySelector('.modal-container')
const tbody = document.querySelector('tbody')

const btnSalvar = document.querySelector('#btnSalvar')

const sBanco = document.querySelector('#m-banco')
const sTipo = document.querySelector('#m-tipo')
const sNomeArquivo = document.querySelector('#m-nomeArquivo')
const sArquivo = document.querySelector('#m-arquivo')
const sDtGeracao = document.querySelector('#m-dtGeracao')
const sUsuarioGeracao = document.querySelector('#m-usuarioGeracao')
const sDtEnvio = document.querySelector('#m-dtEnvio')
const sQtdLinhas = document.querySelector('#m-qtdLinhas')
const sVlrTotal = document.querySelector('#m-vlrTotal')
const sDataInicial = document.querySelector('#m-dataInicial')
const sDataFinal = document.querySelector('#m-dataFinal')

let itens
let id


function openModal(edit = false, index = 0) {
  modal.classList.add('active')

  modal.onclick = e => {
    if (e.target.className.indexOf('modal-container') !== -1) {
      modal.classList.remove('active')
    }
  }

  if (edit) {
    
    sBanco.value = itens[index].banco
    sTipo.value = itens[index].tipo
    sArquivo.value = itens[index].arquivo
    sDtGeracao.value = itens[index].dtGeracao
    sUsuarioGeracao.value = itens[index].usuarioGeracao
    sDtEnvio.value = itens[index].dtEnvio
    sQtdLinhas.value = itens[index].qtdLinhas
    sVlrTotal.value = itens[index].vlrTotal

    id = index
  } else {
    
    sBanco.value = ''
    sTipo.value = ''
    sArquivo.value = ''
    sDtGeracao.value = ''
    sUsuarioGeracao.value = ''
    sDtEnvio.value = ''
    sQtdLinhas.value = ''
    sVlrTotal.value = ''
  }
  
}

function editItem(index) {

  openModal(true, index)
}

function deleteItem(index) {
  itens.splice(index, 1)
  setItensBD()
  loadItens()
}

function insertItem(item, index) {
  let tr = document.createElement('tr')

  tr.innerHTML = `
    <td>${item.banco}</td>
    <td>${item.tipo}</td>
    <td>${item.nomeArquivo}</td>
    <td>${item.dtGeracao}</td>
    <td>${item.usuarioGeracao}</td>
    <td>${item.dtEnvio}</td>
    <td>${item.qtdLinhas}</td>
    <td>R$ ${item.vlrTotal}</td>

    <td class="acao">
      <button onclick="editItem(${index})"><i class='bx bx-edit' ></i></button>
    </td>
    <td class="acao">
      <button onclick="deleteItem(${index})"><i class='bx bx-trash'></i></button>
    </td>
  `
  tbody.appendChild(tr)
}

function pesquisarArqvuivos() {
  deleteItem(-1);
  atualizouSelect();
  console.log('Dados da pesquisa: ' + 'Tipo: ' + sTipo.value + ', Nome Arquivo: ' + sNomeArquivo.value + ', Data Inicial: ' + sDataInicial.value + ', Data Final: ' + sDataFinal.value)
  fetch(`http://localhost:8080/api/arquivo/listFiltros`,{
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      method: "POST",
      body: JSON.stringify({
        'tipo': sTipo.value,
        'nomeArquivo': sNomeArquivo.value,
        'dataInicial': sDataInicial.value,
        'dataFinal': sDataFinal.value
      })
    })
    .then(response => response.json())
    .then(data => {
    console.log(data)
    data.forEach((item, index) => {
      let dataGeracaoFormat = new Date(item.dtGeracao)
      item.dtGeracao = (dataGeracaoFormat.getDate()) + "/" + (dataGeracaoFormat.getMonth() + 1) + "/" + dataGeracaoFormat.getFullYear()
      let dataEnvioFormat = new Date(item.dtEnvio)
      item.dtEnvio = (dataEnvioFormat.getDate()) + "/" + (dataEnvioFormat.getMonth() + 1) + "/" + dataEnvioFormat.getFullYear()
      insertItem(item, index)
    })
  })
    
}

function atualizouSelect() {
  let select = document.querySelector('#m-tipoArquivo');
  let optionValue = select.options[select.selectedIndex];
  sTipo.value = optionValue.value;
}

btnSalvar.onclick = e => {
  
  if (sBanco.value == '' || sTipo.value == '' || sArquivo.value == '' || sDtGeracao.value == '' || sUsuarioGeracao.value == '' || sDtEnvio.value == '' || sQtdLinhas.value == '' || sVlrTotal.value == '') {
    return
  }

  e.preventDefault();

  if (id !== undefined) {
    
    itens[id].banco = sBanco.value
    itens[id].tipo = sTipo.value
    itens[id].arquivo = sArquivo.value
    itens[id].dtGeracao = sDtGeracao.value
    itens[id].usuarioGeracao = sUsuarioGeracao.value
    itens[id].dtEnvio = sDtEnvio.value
    itens[id].qtdLinhas = sQtdLinhas.value
    itens[id].vlrTotal = sVlrTotal.value

  } else {
    
    itens.push({'banco': sBanco.value, 'tipo': sTipo.value, 'arquivo': sArquivo.value, 'dtGeracao': sDtGeracao.value, 'usuarioGeracao': sUsuarioGeracao.value, 'dtEnvio': sDtEnvio.value, 'qtdLinhas': sQtdLinhas.value, 'vlrTotal': sVlrTotal.value})
    
    fetch("http://localhost:8080/api/arquivo/save",{
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      method: "POST",
      body: JSON.stringify({
        'banco': sBanco.value,
        'tipo': sTipo.value,
        'nomeArquivo': sNomeArquivo.value,
        'dtGeracao': sDtGeracao.value,
        'usuarioGeracao': sUsuarioGeracao.value,
        'dtEnvio': sDtEnvio.value,
        'qtdLinhas': sQtdLinhas.value,
        'vlrTotal': sVlrTotal.value
      })
    })
    .then(function (res) { console.log(res) })
    .catch(function (res) { console.log(res) })
  }

  setItensBD()
  console.log(sBanco.value)

  modal.classList.remove('active')
  loadItens()
  id = undefined
}

function loadItens() {
  itens = getItensBD()
  tbody.innerHTML = ''
  itens.forEach((item, index) => {
    insertItem(item, index)
  })

}

const getItensBD = () => JSON.parse(localStorage.getItem('dbfunc')) ?? []
const setItensBD = () => localStorage.setItem('dbfunc', JSON.stringify(itens))

loadItens()