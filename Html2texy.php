<?php #:mode=php:folding=explicit:collapseFolds=1:

/**
 *
 * Html2texy
 *
 * Copyright (C) 2007 Jakub Roztocil <jakub@webkitchen.cz>
 *
 *
 * $h2t = new Html2texy();
 * $h2t->setParam($key, $value);
 * echo $h2t->convert($html);
 *
 */

class Html2texy {

	private $config = array (
		'ignore-empty-divs' => true,
		'ignore-all-divs' => false
	);

	private $proc;

	public function __construct() {
		$this->proc = new XSLTProcessor();
		$this->proc->registerPHPFunctions();
		$style = new DOMDocument('1.0', 'utf-8');
		$style->load(dirname(__FILE__) . '/html2texy.xsl');
		$this->proc->importStylesheet($style);
		foreach ($this->config as $k => $v) {
			$this->proc->setParameter('', $k, $v);
		}
	}

	public function convert($html) {
		// TODO: charsets
		$html = $this->prepareHtml($html);
		$htmlDoc = new DOMDocument();
		@$htmlDoc->loadHTML($html);
		return $this->proc->transformToXml($htmlDoc);
	}

	public function setParam($k, $v) {
		$this->proc->setParameter('', $k, $v);
	}

	private function prepareHtml($html) {
		// Remove doctype and namespaces
		$html = preg_replace('/xmlns=[\'"].+[\'"]|<!DOCTYPE[^>]>|<html[^>]+>/', '', $html);
		$html = '<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /></head>' . $html;
		return $html;
	}


}


