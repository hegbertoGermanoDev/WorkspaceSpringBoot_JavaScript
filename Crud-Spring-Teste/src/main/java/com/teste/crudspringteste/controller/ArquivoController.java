package com.teste.crudspringteste.controller;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.Scanner;

import javax.sql.rowset.serial.SerialException;

import com.teste.crudspringteste.dao.ArquivoMapper;
import com.teste.crudspringteste.model.Arquivo;
import com.teste.crudspringteste.model.ArquivoVO;
import com.teste.crudspringteste.repository.ArquivoRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import lombok.AllArgsConstructor;

@RestController
@RequestMapping("/api/arquivo")
@AllArgsConstructor
public class ArquivoController {
    
    @Autowired
    private ArquivoRepository arquivoRepository;

    @Autowired
    ArquivoMapper arquivoMapper;

    /**
     * 
     * @return toda a listagem de arquivos
     */
    @GetMapping(path = "/list")
    public List<Arquivo> list() {
        return arquivoMapper.getAllArquivos();
    }

    /**
     * @GET
     * @return listagem de arquivos por filtros preenchidos na url
     */
    @GetMapping(path = "/listFiltros")
    public List<Arquivo> listFiltros(@RequestParam String tipo,
                                     @RequestParam String nomeArquivo,
                                     @RequestParam String dataInicial,
                                     @RequestParam String dataFinal) {
        ArquivoVO arquivoVO = new ArquivoVO();
        arquivoVO.setNomeArqvuivo(nomeArquivo);
        arquivoVO.setTipo(tipo);
        arquivoVO.setDataInicial(dataInicial);
        arquivoVO.setDataFinal(dataFinal);
        return arquivoMapper.listArquivosByFiltro(arquivoVO);
    }

    /**
     * @POST
     * @param arquivoVO
     * @return listagem de arquivos por filtros preenchidos no body
     */
    @PostMapping(path = "/listFiltros")
    public List<Arquivo> listFiltros(@RequestBody ArquivoVO arquivoVO) {
        return arquivoMapper.listArquivosByFiltro(arquivoVO);
    }

    @GetMapping(path = "/getArquivoById")
    public Optional<Arquivo> getArqvuivoById(@RequestParam Long id) {
        return arquivoRepository.findById(id);
    }

    /**
     * Executar pelo postman para inserir arquivos iniciais
     * http://localhost:8080/api/arquivo/save
     * body: type: form-data, key: arquivo, value: file
     * @param arquivo
     * @return arquivo salvo
     * @throws IOException
     * @throws SerialException
     * @throws SQLException
     */
    @PostMapping(path = "/save")
    @ResponseStatus(HttpStatus.CREATED)
    public Arquivo save(MultipartFile arquivo, String banco, String vlrTotal, Long id) throws IOException {
        int qtdLinhas = 0;
        String extensaoArq = "";
        Arquivo arquivoSave = new Arquivo();
        
        if (id != 0L) {
            arquivoSave.setId(id);
        }

        /*Buscando caminho raiz do projeto para salvar arquivos iniciais*/
        Path path = Paths.get("");
		String raizProjeto = path.toAbsolutePath().toString();
        byte[] bytes = arquivo.getBytes();
        Path caminho = Paths.get(raizProjeto+"/arquivosUpload/"+arquivo.getOriginalFilename());
        Files.write(caminho, bytes);
        
        arquivoSave.setArquivo(arquivo.getBytes());
        
        arquivoSave.setNomeArquivo(arquivo.getOriginalFilename());
        arquivoSave.setBanco(banco);
        
        arquivoSave.setDtEnvio(new Date());
        arquivoSave.setDtGeracao(new Date());
        
        /*Contagem de linhas do arquivo*/
        Scanner sc = new Scanner(arquivo.getInputStream());
        while (sc.hasNextLine()) {
            sc.nextLine();
            qtdLinhas++;
        }
        arquivoSave.setQtdLinhas(qtdLinhas);
        sc.close();
        
        /*Identificar extensão do arquivo*/
        if (arquivo.getOriginalFilename().contains(".")) {
            extensaoArq = arquivo.getOriginalFilename().substring(arquivo.getOriginalFilename().lastIndexOf(".") + 1);
        }
        else {
            extensaoArq = "SEMEXTENSAO";
        }
        arquivoSave.setTipo(extensaoArq);

        arquivoSave.setUsuarioGeracao("USUTESTE");
        vlrTotal = vlrTotal.replace(",", ".");
        arquivoSave.setVlrTotal(Double.parseDouble(vlrTotal));
        return arquivoRepository.save(arquivoSave);
    }

    @GetMapping(path = "/downloadArquivo")
    public ResponseEntity<Resource> downloadArquivo(@RequestParam String nomeArquivo) throws FileNotFoundException, SerialException, SQLException {
        Arquivo arquivo = new Arquivo();
        arquivo.setNomeArquivo(nomeArquivo);
        Arquivo arquivoRet = arquivoMapper.getArquivoByNomeArquivo(arquivo);
        //return arquivoRet;
        Path path = Paths.get("");
		String raizProjeto = path.toAbsolutePath().toString();
        Path caminho = Paths.get(raizProjeto+"/arquivosUpload/"+arquivoRet.getNomeArquivo());
        InputStreamResource resource = new InputStreamResource(new FileInputStream(caminho.toFile()));
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType("application/octet-stream"))
                .header(HttpHeaders.CONTENT_DISPOSITION,"attachment;filename=\""+arquivoRet.getNomeArquivo()+"\"")
                .body(resource);
        
    }

    @GetMapping(path = "/deleteArquivo")
    public void deleteArquivo(@RequestParam Long id) {
        arquivoRepository.deleteById(id);
    }

}
