// @ts-check
// `@type` JSDoc annotations allow editor autocompletion and type checking
// (when paired with `@ts-check`).
// There are various equivalent ways to declare your Docusaurus config.
// See: https://docusaurus.io/docs/api/docusaurus-config

// October 21, 2025 - Import themes for syntax highlighting
import {themes as prismThemes} from 'prism-react-renderer';
//const lightCodeTheme = require('prism-react-renderer').themes.github;
//const darkCodeTheme = require('prism-react-renderer').themes.palenight;

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'How to Set Up a Cardano Stake Pool',
  tagline: '',
  favicon: 'img/favicon.ico',

  // Future flags, see https://docusaurus.io/docs/api/docusaurus-config#future
  future: {
    v4: true, // Improve compatibility with the upcoming Docusaurus v4
  },

  // Set the production url of your site here
  url:  'https://coincashew.io',
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  //baseUrl: '/',
  baseUrl: '/spo/',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'ChangePool', // Usually your GitHub org/user name.
  projectName: 'CardanoSPOGuide', // Usually your repo name.

  onBrokenLinks: 'throw',
  // September 26, 2025 - The onBrokenMarkdownLinks configuration option is deprecated in Docusaurus v4
  // onBrokenMarkdownLinks: 'warn',

  // September 26, 2025 - The following Markdown configuration is introduced in Docusaurus v3.9.1 For more details, see https://docusaurus.io/docs/api/docusaurus-config
  markdown: {
    format: 'mdx',
    mermaid: true,
    emoji: true,
    preprocessor: ({filePath, fileContent}) => {
      return fileContent.replaceAll('{{MY_VAR}}', 'MY_VALUE');
    },
    parseFrontMatter: async (params) => {
      const result = await params.defaultParseFrontMatter(params);
      result.frontMatter.description =
        result.frontMatter.description?.replaceAll('{{MY_VAR}}', 'MY_VALUE');
      return result;
    },
    mdx1Compat: {
      comments: true,
      admonitions: true,
      headingIds: true,
    },
    anchors: {
      maintainCase: true,
    },
    hooks: {
      onBrokenMarkdownLinks: 'warn',
      onBrokenMarkdownImages: 'throw',
    },
  },

  // Even if you don't use internationalization, you can use this field to set
  // useful metadata like html lang. For example, if your site is Chinese, you
  // may want to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  //
  // August 30, 2025 - The plugin-sitemap plugin is included in the @docusaurus/preset-classic preset
  //
  //plugins: [
  //  [
  //    '@docusaurus/plugin-sitemap',
  //    {
  //      // plugin options
  //    },
  //  ],
  //],

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: './sidebars.js',
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          //editUrl:
          //  'https://github.com/ChangePool/CardanoSPOGuide',
          // August 17, 2025 - Enable docs-only mode to remove the default landing page
          routeBasePath: '/',
        },
        // August 17, 2025 - Disable the Blog plugin
        blog: false,
        //blog: {
        //  showReadingTime: true,
        //  feedOptions: {
        //    type: ['rss', 'atom'],
        //    xslt: true,
        //  },
        //  // Please change this to your repo.
        //  // Remove this to remove the "edit this page" links.
        //  editUrl:
        //    'https://github.com/ChangePool/CardanoSPOGuide',
        //  // Useful options to enforce blogging best practices
        //  onInlineTags: 'warn',
        //  onInlineAuthors: 'warn',
        //  onUntruncatedBlogPosts: 'warn',
        //},
        theme: {
          customCss: './src/css/custom.css',
        },
        //
        // August 31, 2025 - Configure generation of the sitemap.xml file that the DocSearch
        // Scraper uses to index the site for the Typesense Server, enabling the Search field.
        //
        // NOTE: Typesense is open source and based on Algolia (https://docsearch.algolia.com/)
        //
        // For more details, visit:
        //
        //   - https://docusaurus.io/docs/api/plugins/@docusaurus/plugin-sitemap
        //   - https://typesense.org/docs/guide/docsearch.html
        //   - https://typesense.org/docs/guide/install-typesense.html
        //
        sitemap: {
          lastmod: 'datetime',
          changefreq: 'weekly',
          priority: 0.5,
          ignorePatterns: [],
          filename: 'sitemap.xml',
        },
      }),
    ],
  ],

  //
  // August 30, 2025 - Use the docusaurus-theme-search-typesense plugin to add a Search bar to the site.
  //
  // NOTE: For details on styling the Search bar, see https://docusaurus.io/docs/search#styling-your-algolia-search
  //
  themes: [
    'docusaurus-theme-search-typesense',
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/CCSocialCard.png',
      navbar: {
        title: 'How to Set Up a Cardano Stake Pool',
        logo: {
          alt: 'Logo',
          src: 'img/CCLogoLarge.png',
          //
          // August 17, 2025 - Link the navbar logo to the Home page for the Guide rather than the landing page.
          //
          // NOTE: To set the link to the landing page, comment out the following line using //
          //
          // NOTE: The coincashew.io docusaurus site runs in docs-only mode. For more details, see the routeBasePath
          // option above. To set a page in the /docs folder to open as the starting page for the site, rename the
          // /src/pages/index.js file, and then add slug: / to the frontmatter of the file in the /docs folder
          // that you want to set as the starting page. For example, see the file /docs/intro.md
          //
          //href: '/intro',
        },
        items: [
          // August 17, 2025 - Remove the Tutorial link from the navbar
          //{
          //  type: 'docSidebar',
          //  sidebarId: 'tutorialSidebar',
          //  position: 'left',
          //  label: 'How to Set Up a Cardano Stake Pool',
          //},
          // August 17, 2025 - Remove the Blog link from the navbar
          //{to: '/blog', label: 'Blog', position: 'left'},
          {
            href: 'mailto:doc@coincashew.io?subject=CoinCashew Guide',
            label: 'E-mail',
            position: 'right',
          },
          {
            href: 'https://github.com/ChangePool/CardanoSPOGuide',
            label: 'GitHub',
            position: 'right',
          },
          {
            href: 'https://discord.gg/dEpAVWgFNB',
            label: 'Discord',
            position: 'right',
          },
        ],
      },
      // August 17, 2025 - Set the sidebar to be hideable
      docs: {
        sidebar: {
          hideable: true,
        },
      },
      footer: {
        style: 'dark',
        links: [
          // August 17, 2025 - Remove the Docs link from the footer
          //{
          //  title: 'Docs',
          //  items: [
          //    {
          //      label: 'Tutorial',
          //      to: '/docs/intro',
          //    },
          //  ],
          //},
          //{
            //title: 'Community',
            //items: [
              // August 17, 2025 - Remove the Stack Overflow link from the footer
              //{
              //  label: 'Stack Overflow',
              //  href: 'https://stackoverflow.com/questions/tagged/docusaurus',
              //},
              //{
                //label: 'Discord',
                //href: 'https://discord.gg/dEpAVWgFNB',
              //},
              // August 17, 2025 - Remove the Twitter link from the footer
              //{
              //  label: 'X',
              //  href: 'https://x.com/docusaurus',
              //},
              // August 17, 2025 - Add a link to the CoinCashew Reddit channel
              //{
              //  label: 'Reddit',
              //  href: 'https://www.reddit.com/r/coincashew/',
              //},
            //],
          //},
          //{
            //title: 'More',
            //title: 'Contribute',
            //items: [
              // August 17, 2025 - Remove the Blog link from the footer
              //{
              //  label: 'Blog',
              //  to: '/blog',
              //},
              //{
                //label: 'GitHub',
                //href: 'https://github.com/ChangePool/CardanoSPOGuide',
              //},
            //],
          //},
        ],
        // August 17, 2025 - License the Guide in the public domain
        //copyright: `Copyright © ${new Date().getFullYear()} | Presented by CoinCashew | Built Using Docusaurus.`,
        // copyright: 'Creative Commons Attribution 4.0 International | Presented by CoinCashew | Created Using Docusaurus',
        // copyright: 'Hosted by <a href="https://coincashew.io" target="_blank">Change [CHG] Stake Pool</a> | Presented by CoinCashew | Published Using Docusaurus',
        copyright: 'Hosted by <a href="https://coincashew.io" target="_blank">Change [CHG] Stake Pool</a><br />Presented by CoinCashew',
      },
      prism: {
        // October 21, 2025 - Set themes for syntax highlighting
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
        //darkTheme: prismThemes.palenight,
        //theme: lightCodeTheme,
        //darkTheme: darkCodeTheme,
        additionalLanguages: [
          // October 12, 2025 - Enable syntax highlighting for Bash scripts and JSON files
          'bash',
          'json',
          'shell-session',
        ],
      },
      //
      // August 30, 2025 - Configure the Typesense integration
      //
      typesense: {
        // Replace this with the name of your index/collection.
        // It should match the "index_name" entry in the scraper's "config.json" file.
        typesenseCollectionName: 'CCSPOGuide',
        typesenseServerConfig: {
          nodes: [
            {
              host: 'nt2.paradoxicalsphere.com',
              port: 8108,
              protocol: 'https',
            },
          ],
          apiKey: 'qzAbvb4MrA1I52mfscRtDiwiDbdAmHezkxiRRmzvZjfpUgja',
        },
        // Optional: Typesense search parameters: https://typesense.org/docs/0.24.0/api/search.html#search-parameters
        typesenseSearchParameters: {},
        // Optional: Contextual Search ensures that search results are relevant to the current language and version:
        // https://docusaurus.io/docs/3.4.0/search#contextual-search
        contextualSearch: true,
      },
    }),
};

export default config;
