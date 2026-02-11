import React from 'react';

import useBaseUrl from '@docusaurus/useBaseUrl';

export default function TestnetNote() {

  return (
    <div>
      <table class="box">
        <tbody>
          <tr>
            <td class="boxLabel"><p class="boxLabel">Note<br /><img src={useBaseUrl('img/BoxNote.png')} alt="Note" /></p></td>
            <td class="boxText"><p class="boxText">Cardano CLI commands throughout the <i>How to Set Up a Cardano Stake Pool</i> guide may use the <code>&#8209;&#8209;mainnet</code> option. If you are working in a Testnet environment, then remember to replace each instance of the <code>&#8209;&#8209;mainnet</code> option with <code>&#8209;&#8209;testnet&#8209;magic &lt;MagicNumber&gt;</code> where <code>&lt;MagicNumber&gt;</code> is the network magic number for the Testnet that you use.</p></td>
          </tr>
        </tbody>
      </table>
    </div>
  );
}

