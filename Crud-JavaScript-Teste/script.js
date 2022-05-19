
const modal = document.querySelector('.modal-container')
const modalExc = document.querySelector('.modal-container-exc')
const tbody = document.querySelector('tbody')

const btnSalvar = document.querySelector('#btnSalvar')

const sBanco = document.querySelector('#m-banco')
const sTipo = document.querySelector('#m-tipo')
const sTipoArquivo = document.querySelector('#m-tipoArquivo')
const sNomeArquivo = document.querySelector('#m-nomeArquivo')
const sArquivo = document.querySelector('#m-arquivo')
const sDtGeracao = document.querySelector('#m-dtGeracao')
const sUsuarioGeracao = document.querySelector('#m-usuarioGeracao')
const sDtEnvio = document.querySelector('#m-dtEnvio')
const sQtdLinhas = document.querySelector('#m-qtdLinhas')
const sVlrTotal = document.querySelector('#m-vlrTotal')
const sDataInicial = document.querySelector('#m-dataInicial')
const sDataFinal = document.querySelector('#m-dataFinal')

let itens;
let id;
let idArqSelTab;
let indexArqSelTab;
let operacaoRegistro;
init();

function init() {
  pesquisarArqvuivosGet(null);
}

function openModal(edit = false, index = 0) {
  modal.classList.add('active')
  modal.onclick = e => {
    if (e.target.className.indexOf('modal-container') !== -1) {
      modal.classList.remove('active')
    }
  }
  
  if (edit) {
    indexArqSelTab = index+1;
    itens = document.getElementById("listArquivos");
    idArqSelTab = itens.rows[index+1].cells[0].innerHTML;
    let banco = itens.rows[index+1].cells[1].innerHTML;
    let nomeArquivo = itens.rows[index+1].cells[3].innerHTML;
    var vlrTotal = itens.rows[index+1].cells[8].innerHTML;
    vlrTotal = vlrTotal.replace('R$ ','');
    console.log(vlrTotal);
    sBanco.value = banco;
    sNomeArquivo.value = nomeArquivo;
    sVlrTotal.value = vlrTotal;
    operacaoRegistro = 'edit';
    idUpdate = idArqSelTab;
  } else {
    idArqSelTab = null;
    indexArqSelTab = null;
    sBanco.value = '';
    sNomeArquivo.value = '';
    sVlrTotal.value = '';
    operacaoRegistro = 'save';
  }
}

function editItem(index) {
  openModal(true, index);
}

function deleteItem(index) {
  indexArqSelTab = index+1;
  itens = document.getElementById("listArquivos");
  idArqSelTab = itens.rows[index+1].cells[0].innerHTML;
  console.log(idArqSelTab);
  modalExc.classList.add('active');
  modalExc.onclick = e => {
    if (e.target.className.indexOf('modal-container-exc') !== -1) {
      modalExc.classList.remove('active')
    }
  }
}

let formConfExc = document.getElementById('formConfirmExc');
formConfExc.addEventListener('submit',confirmarExclusaoAsync);
async function confirmarExclusaoAsync(event) {
  event.preventDefault();
  if (idArqSelTab != null) {
    const response = await fetch(`http://localhost:8080/api/arquivo/deleteArquivo/?id=${idArqSelTab}`)
    if (response.status = 200) {
      console.log(response);
      modalExc.classList.remove('active');
      pesquisarArqvuivosGet(event);
    }
  }
  else {
    idArqSelTab = null;
    indexArqSelTab = null;
    modalExc.classList.remove('active');
  }
}

function cancelarExclusao() {
  idArqSelTab = null;
  indexArqSelTab = null;
  modalExc.classList.remove('active');
}

function insertItem(item, index) {
  let tr = document.createElement('tr')

  tr.innerHTML = `
    <td class="some">${item.id}</td>
    <td>${item.banco}</td>
    <td>${item.tipo}</td>
    <td>${item.nomeArquivo}</td>
    <td>${item.dtGeracao}</td>
    <td>${item.usuarioGeracao}</td>
    <td>${item.dtEnvio}</td>
    <td>${item.qtdLinhas}</td>
    <td>R$ ${item.vlrTotal}</td>

    <td class="acao">
      <button onclick="downloadArquivo(${index})"><i class='bx bx-download' ></i></button>
    </td>
    <td class="acao">
      <button onclick="editItem(${index})"><i class='bx bx-edit' ></i></button>
    </td>
    <td class="acao">
      <button onclick="deleteItem(${index})"><i class='bx bx-trash'></i></button>
    </td>
  `
  tbody.appendChild(tr)
}

function limparTable() {
  var table = document.getElementById("listArquivos");
  var rowCount = table.rows.length;
  for (var i=rowCount-1; i >0; i--) {
    table.deleteRow(i);
  }
}

let formPesq = document.getElementById('formPesquisar');
formPesq.addEventListener('submit',pesquisarArqvuivosGet);
function pesquisarArqvuivosGet(event) {
  if (event != null) {
    event.preventDefault();
  }
  limparTable();
  atualizouSelect();
  const formatDateUnit = unit => String(unit).length === 1 ? `0${unit}` : unit;
  var dateIni = null;
  var dateFin = null;
  var dataInicialStr = "";
  var dataFinalStr = "";
  if (document.getElementById("m-dataInicial").value != "") {
    dateIni = new Date(document.getElementById("m-dataInicial").value);
    dataInicialStr = formatDateUnit(dateIni.getDate())+"/"+formatDateUnit(dateIni.getMonth()+1)+"/"+dateIni.getFullYear();
  }
  if (document.getElementById("m-dataFinal").value != "") {
    dateFin = new Date(document.getElementById("m-dataFinal").value);
    dataFinalStr = formatDateUnit(dateFin.getDate())+"/"+formatDateUnit(dateFin.getMonth()+1)+"/"+dateFin.getFullYear();
  }
  console.log('URL GET: ' + `http://localhost:8080/api/arquivo/listFiltros/?tipo=${sTipoArquivo.value}&nomeArquivo=${sNomeArquivo.value}&dataInicial=${dataInicialStr}&dataFinal=${dataFinalStr}`)
  fetch(`http://localhost:8080/api/arquivo/listFiltros/?tipo=${sTipoArquivo.value}&nomeArquivo=${sNomeArquivo.value}&dataInicial=${dataInicialStr}&dataFinal=${dataFinalStr}`)
  .then(response => response.json())
  .then(data => {
    data.forEach((item, index) => {
      let dataGeracaoFormat = new Date(item.dtGeracao);
      let dataEnvioFormat = new Date(item.dtEnvio);
      item.dtGeracao = formatDateUnit(dataGeracaoFormat.getDate())+"/"+formatDateUnit(dataGeracaoFormat.getMonth()+1)+"/"+dataGeracaoFormat.getFullYear();
      item.dtEnvio = formatDateUnit(dataEnvioFormat.getDate())+"/"+formatDateUnit(dataEnvioFormat.getMonth()+1)+"/"+dataEnvioFormat.getFullYear();
      insertItem(item, index);
    })
  })
}

let formInsOrUpd = document.getElementById('formSaveOrUpdate');
formInsOrUpd.addEventListener('submit',uploadArquivoAsync);
async function salvarArquivo(event) {
  await uploadArquivoAsync(event);
}
async function uploadArquivoAsync(event) {
  event.preventDefault();
  console.log(document.getElementById('m-arquivo').files[0]);
  let formData = new FormData(formInsOrUpd);
  formData.append("arquivo",document.getElementById('m-arquivo').files[0])
  formData.append("banco",document.getElementById('m-banco').value)
  formData.append("vlrTotal",document.getElementById('m-vlrTotal').value)
  if (operacaoRegistro == 'save') {
    formData.append("id",0);
    const response = await fetch("http://localhost:8080/api/arquivo/save",{
      method: "POST",
      body: formData
    })
    const data = await response.json();
  } else if (operacaoRegistro == 'edit') {
    formData.append("id",idArqSelTab);
    const response = await fetch("http://localhost:8080/api/arquivo/save",{
      method: "POST",
      body: formData
    })
    const data = await response.json();
  }
}

function downloadArquivo(index) {
  itens = document.getElementById("listArquivos");
  const nomeArquivo = itens.rows[index+1].cells[3].innerHTML;
  console.log(nomeArquivo);
  fetch(`http://localhost:8080/api/arquivo/downloadArquivo/?nomeArquivo=${nomeArquivo}`)
    .then(res => res.blob())
    .then(data => {
      console.log(data);
      var file = new File([data], nomeArquivo);
      var a = document.createElement("a");
      var url = window.URL.createObjectURL(file);
      a.href = url;
      a.download = nomeArquivo;
      document.body.appendChild(a);
      a.click();
      setTimeout(function() {
          document.body.removeChild(a);
          window.URL.revokeObjectURL(url);
      }, 0);
      
    })
}

function atualizouSelect() {
  let select = document.querySelector('#m-tipoArquivo');
  let optionValue = select.options[select.selectedIndex];
  sTipoArquivo.value = optionValue.value;
}

function limparCamposPesquisa() {
  document.querySelector('#m-tipoArquivo').value = '';
  sNomeArquivo.value = '';
  sDataInicial.value = '';
  sDataFinal.value = '';
  limparTable();
}