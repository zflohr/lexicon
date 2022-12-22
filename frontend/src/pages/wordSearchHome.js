import React, { Component } from 'react';
import searchIcon from './../images/search_FILL0_wght700_GRAD200_opsz48.svg';
import axios from 'axios';
import { Form, redirect } from "react-router-dom";

const wordSearchHomeLoader = ({ request }) => {
   let url = new URL(request.url);
   let searchTerm = url.searchParams.get('wordSearch');
   console.log(searchTerm);
   if (searchTerm == null) return null;
   else return redirect(`/${searchTerm}`);
};

class WordSearchHome extends Component {

   constructor(props) {
      super(props);
      this.axiosConfig = axios.create({
	 baseURL: 'http://127.0.0.1'
      });
      this.state = {value: ''};
      this.handleChange = this.handleChange.bind(this);
      this.handleSubmit = this.handleSubmit.bind(this);
   }

   handleChange(event) {
      this.setState({value: event.target.value});
   }

   
   handleSubmit(event) {
      /* event.preventDefault();
      this.axiosConfig.get('/get-lexicographic-data/', {
	 params: {
	    word: this.state.value
	 }
      }); */
   }

   render() {

      return (
	 <header className="header vertical-flex">
	    <h1 className="heading-1">A Dictionary of the English Language</h1>
	    <Form acceptCharset="utf-8" 
	       autoCapitalize="none" 
	       autoComplete="off" 
	       method="get"
	       onSubmit={this.handleSubmit}
	    >
	       <label className="label" 
		  htmlFor="dictionarySearch"
	       >
		  Search for a Word
	       </label>
	       <div className="horizontal-flex">
		  <input className="search-button-box search-box"
		     type="text" 
		     id="dictionarySearch"
		     name="wordSearch"
		     value={this.state.value}
		     onChange={this.handleChange}
		  />
		  <input className="search-button-box"
		     alt="Get lexicographic data" 
		     src={searchIcon} 
		     type="image" 
		  />
	       </div>
	    </Form>
	 </header>
      );
   }
}

export { WordSearchHome as default, wordSearchHomeLoader };