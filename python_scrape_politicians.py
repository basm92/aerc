import bs4
import re
from langchain_community.document_loaders import WebBaseLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from urllib.parse import urljoin

# Only keep post title, headers, and content from the full HTML.
bs4_strainer = bs4.SoupStrainer(class_=("layout-content"))
loader = WebBaseLoader(
    web_paths=("https://www.parlement.com/raad-van-state-leden-1862-heden",),
    bs_kwargs={"parse_only": bs4_strainer},
)

soup = loader.scrape()
base_url = "https://www.parlement.com"
hyperlinks = [urljoin(base_url, link.get("href")) for link in soup.find_all("a") if link.get("href")]

loader = WebBaseLoader(
    web_paths=hyperlinks,
    bs_kwargs={"parse_only": bs4_strainer},
)

documents = loader.load()

# Clean the content of the documents IN PLACE
for doc in documents:
    # Replace 3 or more newlines with just 2 (standard paragraph break)
    doc.page_content = re.sub(r'\n{3,}', '\n\n', doc.page_content)
    # Strip leading/trailing whitespace
    doc.page_content = doc.page_content.strip()

# 1. Define the splitter
# chunk_size=1000: Roughly 2-3 paragraphs. Good for retrieving a specific career phase.
# chunk_overlap=200: Ensures context (like the person's name) isn't lost at the edges.
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", " ", ""] # It will try to split by double newlines first
)

# Now split
split_docs = text_splitter.split_documents(documents)
