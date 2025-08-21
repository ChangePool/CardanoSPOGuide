---
title: "Appendix C: Styles & Standards"
sidebar_label: "Appendix C: Styles & Standards"
slug: /AppendixC
hide_title: false
sidebar_position: 65
---

import React from 'react';

export function HTMLContent() {
  return (
    <div>
      <p><i>Appendix C</i> explains how to revise the <i>How to Set Up a Cardano Stake Pool</i> guide, including a style guide showing in context how to use all available HTML styles.</p>
      <h1>Editing the Guide</h1>
      <p>Explain how to clone the GitHub repository; install Docusaurus; and, edit the Guide.</p>
      <h1>Style Guide</h1>
      <p>In the comprehensive sample text below, the HTML tag for each style or the path to a file containing an HTML snippet for the style appears in parentheses.</p>
      <h1>Heading 1 (h1)</h1>
      <p>Paragraph Text (p)—Mauris sed erat ac urna sollicitudin consequat et et ipsum. Ut viverra quis elit eget feugiat. Pellentesque pulvinar placerat ligula, ac rhoncus est dignissim consequat. Suspendisse pellentesque, leo ut blandit tristique, odio mi ultricies mi, eu sodales erat mi sed elit. Donec tincidunt in orci ut condimentum. Etiam eu massa in metus auctor interdum. Proin eleifend fringilla tortor, vitae bibendum augue semper id. Donec et varius massa, at commodo sapien. Nulla lectus dolor, varius vel mollis at, condimentum et nibh. In vulputate in ante non placerat. Fusce bibendum dolor sit amet molestie faucibus.</p>
      <table id="<UniqueID>" class="box">
        <tbody>
          <tr>
            <td width="125pt"><p class="boxLabel">Important</p></td>
            <td><p class="boxText">Important Box (snippets/src/important.htm)—Curabitur facilisis turpis vel augue malesuada venenatis. Nulla ac iaculis arcu, a ornare mauris. Praesent molestie aliquam lectus, blandit blandit magna.</p></td>
          </tr>
        </tbody>
      </table>
      <p>Paragraph Text (p)—Morbi vulputate elit sapien, a dignissim tortor vulputate eu. Nam imperdiet sapien vulputate, malesuada enim sit amet, venenatis ipsum. Morbi fringilla nunc sit amet iaculis accumsan. Suspendisse ultricies tempus augue, ut vulputate ipsum. Vivamus imperdiet fringilla lectus at porttitor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et magna in dolor vulputate pulvinar. Nulla molestie rhoncus rutrum.</p>
      <h2>Heading 2 (h2)</h2>
      <p>Paragraph Text (p)—Quisque vitae lorem suscipit, posuere elit vitae, rutrum enim. Vestibulum ultricies nisi luctus lobortis efficitur. Donec sit amet diam lacinia, faucibus orci vel, euismod mauris. Nunc a massa tincidunt, ornare magna sit amet, tempus mauris. Donec sed suscipit turpis, egestas iaculis quam. Nunc ut mi at mi condimentum tempor. Curabitur eleifend, nulla nec accumsan tincidunt, nisl lorem iaculis ante, sit amet semper massa orci a lectus. Nam justo nibh, scelerisque quis quam non, scelerisque tristique eros. Cras id nisl non turpis sagittis posuere sed ut turpis. Nulla purus diam, imperdiet at aliquam nec, lacinia eu sapien. Proin aliquet mauris egestas nibh pharetra ornare. Praesent ut convallis ipsum.</p>
      <table id="<UniqueID>" class="box">
        <tbody>
          <tr>
            <td width="125pt"><p class="boxLabel">Note</p></td>
            <td><p class="boxText">Note Box (snippets/src/note.htm)—Sed in nisl vel enim malesuada convallis. Vivamus non mauris est. Donec luctus purus vel facilisis convallis. In hac habitasse platea dictumst.</p></td>
          </tr>
        </tbody>
      </table>
      <p>Paragraph Text (p)—Phasellus in egestas magna, vitae finibus enim. Quisque interdum tortor sit amet lorem condimentum, non gravida ipsum auctor. Aenean ut viverra ligula, ac tincidunt massa. Fusce mollis mauris et congue aliquet. Ut lacinia vehicula turpis eget posuere. Aenean iaculis ac erat id mattis. Sed sit amet dui eu tortor molestie tincidunt.</p>
      <code>function Code()<br />
        &#123;<br />
        &nbsp;&nbsp;&nbsp;&nbsp;Code (code);<br />
        &nbsp;&nbsp;&nbsp;&nbsp;Code (code);<br />
        &nbsp;&nbsp;&nbsp;&nbsp;Code (code);<br />
        &#125;
      </code>
      <p>Paragraph Text (p)—In sit amet mauris laoreet, ultricies diam ut, volutpat neque. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Cras facilisis sapien et ante lacinia imperdiet. Nullam condimentum purus non neque porta, malesuada varius nibh rutrum. Nulla maximus at magna eget tincidunt. Donec non porttitor sem. Nam vitae condimentum est. Etiam id faucibus quam, quis aliquet tortor.</p>
      <p><i>Table 1</i> provides some escape characters that you may need when using JavaScript XML (JSX).</p>
      


      <table id="<UniqueID>" class="center">
        <caption>Table 1 Escape Characters (snippets/src/table.htm)</caption>
        <tbody>
          <tr>
            <th width="34%"><p>Character Name</p></th>
            <th width="33%"><p>Display Character</p></th>
            <th width="33%"><p>Escape Character</p></th>
          </tr>
          <tr>
            <td class="center"><p>Ampersand</p></td>
            <td class="center"><p>&amp;</p></td>
            <td class="center"><p>&amp;amp;</p></td>
          </tr>
          <tr>
            <td class="center"><p>Left Brace</p></td>
            <td class="center"><p>&#123;</p></td>
            <td class="center"><p>&amp;#123;</p></td>
          </tr>
          <tr>
            <td class="center"><p>Right Brace</p></td>
            <td class="center"><p>&#125;</p></td>
            <td class="center"><p>&amp;#125;</p></td>
          </tr>
          <tr>
            <td class="center"><p>Less Than</p></td>
            <td class="center"><p>&lt;</p></td>
            <td class="center"><p>&amp;lt;</p></td>
          </tr>
          <tr>
            <td class="center"><p>Greater Than</p></td>
            <td class="center"><p>&gt;</p></td>
            <td class="center"><p>&amp;gt;</p></td>
          </tr>
          <tr>
            <td class="center"><p>Quotation Mark</p></td>
            <td class="center"><p>&quot;</p></td>
            <td class="center"><p>&amp;quot;</p></td>
          </tr>
          <tr>
            <td class="center"><p>Apostrophe</p></td>
            <td class="center"><p>&apos;</p></td>
            <td class="center"><p>&amp;apos;</p></td>
          </tr>
          <tr>
            <td><p>In sit amet mauris laoreet, ultricies diam ut, volutpat neque.</p><p>Ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Cras facilisis sapien et ante lacinia imperdiet.</p></td>
            <td><p>Curabitur fringilla tristique rutrum.</p>
              <p>Morbi sit amet blandit ipsum.</p>
              <p>Phasellus sed luctus nunc. Integer hendrerit augue mi, gravida cursus leo vestibulum in.</p>
            </td>
            <td><p>Ut eget justo ut erat aliquet semper. Praesent tristique, leo feugiat mollis posuere, lorem dui auctor justo, in pulvinar augue turpis at nisl. Nullam blandit metus at lorem dignissim, suscipit imperdiet tellus euismod. Aenean euismod sapien ut est hendrerit accumsan. Vestibulum vitae volutpat mi.</p></td>
          </tr>
        </tbody>
      </table>





      <p>Paragraph Text (p)—Nulla ullamcorper sed ante ornare vehicula. Etiam gravida convallis sem quis egestas. Duis convallis mi lobortis odio accumsan elementum. Praesent id pulvinar tortor. Etiam volutpat velit a auctor blandit. Fusce dictum aliquam elementum. Nam iaculis lacus sed odio finibus, ac interdum ipsum feugiat. Cras ac leo et arcu condimentum vehicula.</p>
      <p>Unordered List (ul):</p>
      <ul>
        <li>List Item (li)</li>
        <li>List Item (li)—Ipsum dolor sit amet, consectetur adipiscing elit. Cras in eleifend ante, vitae placerat arcu. Duis pharetra mattis fringilla. Quisque consequat fermentum bibendum. Donec commodo ipsum ut justo porta aliquet. Vestibulum a sagittis leo, a convallis elit. Pellentesque elementum placerat arcu eu tristique. Duis in risus egestas dolor consectetur lobortis non vestibulum sem. This is a second-level unordered list (ul):
          <ul>
            <li>List Item (li)</li>
            <li>List Item (li)—Nulla commodo nunc elit, id hendrerit arcu fringilla at. Nullam venenatis massa ut orci iaculis, eu ultrices dolor vulputate. Maecenas vestibulum arcu nec eros viverra, eu finibus risus suscipit. Nullam arcu lacus, auctor et nisl at, posuere pharetra lorem. Nam finibus lobortis ligula vel euismod. Donec nec erat lobortis, pharetra urna quis, dignissim dui. Curabitur lacus mauris, cursus aliquet egestas id, fringilla eget diam.</li>
            <li>List Item (li)</li>
            <li>List Item (li)</li>
          </ul>
        </li>
        <li>List Item (li)</li>
      </ul>
      <h3>Heading 3 (h3)</h3>
      <p>Paragraph Text (p)—Vestibulum faucibus neque nec egestas sagittis. Curabitur felis tortor, dignissim sed ipsum in, dignissim pharetra nulla. Maecenas ac lacus eu orci suscipit volutpat. Curabitur sed urna tristique, varius eros sit amet, imperdiet purus. Etiam in ante in erat bibendum hendrerit. Curabitur eu erat blandit, scelerisque ipsum id, faucibus nunc. Integer dignissim nibh eget turpis ultrices, quis vulputate massa vehicula. Ut a ultricies mi. Maecenas vulputate felis id ipsum accumsan congue. Aenean nec purus a odio pellentesque aliquam sed a nulla.</p>
      <table id="<UniqueID>" class="box">
        <tbody>
          <tr>
            <td width="125pt"><p class="boxLabel">Credit</p></td>
            <td><p class="boxText">Use the Credit Box (snippets/src/credit.htm) to recognize a contributor to the Guide. Integer vitae pharetra augue. Phasellus sit amet risus ac velit porttitor ornare. Interdum et malesuada fames ac ante ipsum primis in faucibus.</p></td>
          </tr>
        </tbody>
      </table>
      <p>Paragraph Text (p)—Morbi vulputate elit sapien, a dignissim tortor vulputate eu. Nam imperdiet sapien vulputate, malesuada enim sit amet, venenatis ipsum. Morbi fringilla nunc sit amet iaculis accumsan. Suspendisse ultricies tempus augue, ut vulputate ipsum. Vivamus imperdiet fringilla lectus at porttitor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec et magna in dolor vulputate pulvinar. Nulla molestie rhoncus rutrum.</p>
      <figure>
        <img src="img/coincashew-social-card.png" />
        <figcaption>Figure Caption (caption)</figcaption>
      </figure>
      <p>Procedure Heading (p.h):</p>
      <ol>
        <li>List Item (li)</li>
        <li>List Item (li)—Sed placerat pulvinar tortor non placerat. Cras ultrices est ipsum, a molestie nibh aliquet feugiat. Nam semper, arcu nec commodo condimentum, libero nibh convallis neque, quis accumsan orci dui ac sapien. In et lorem porttitor, auctor neque eget, porttitor est. Pellentesque ac viverra lacus. Suspendisse bibendum porttitor eros, in molestie mi tristique eget. Aenean id dui congue ante semper aliquet. Pellentesque quis facilisis augue. Nulla sed consectetur quam. Nunc condimentum magna sed felis sodales, quis commodo diam dignissim. Here is a procedure substep (li.ps):
          <ol>
            <li>In lorem justo, placerat nec gravida sed, vestibulum ac diam. Donec pretium erat interdum consequat egestas. Ut gravida lacinia mauris, nec dictum ipsum bibendum quis. Vivamus ac congue ex. Integer auctor nisi ex, ac consectetur eros molestie rhoncus. Mauris eu bibendum metus, id blandit velit. Maecenas in augue eu tellus convallis luctus non quis ipsum. Phasellus dictum orci id interdum sollicitudin. Cras cursus quis sem id convallis. Nam et pharetra arcu, at vehicula felis.</li>
            <li>Second procedure substep</li>
          </ol>
        </li>
        <li>List item</li>
      </ol>
      <h4>h4 (Heading 4)</h4>
      <p>Paragraph Text (p)</p>
    </div>
  );
}

<HTMLContent />
